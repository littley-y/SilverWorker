# spec_17 — 안면 확인 출근 인증 (Liveness Attendance)

> 상태: 기획 확정 (2026-05-14)
> 범위: 출퇴근 시 안면 확인을 통한 본인 인증
> 난이도: ↑↑ (백엔드 + 카메라 + AWS 통합)
> 우선순위: P2 (2차 구현 4순위, 유료 전환 시점 권장)
> 선행 조건: spec_14 (LLM 인프라), spec_16 (AI 기능 안정화)

---

## 1. 목표

출퇴근 시 사용자가 **스마트폰 카메라로 자신의 얼굴을 비추면**, 시스템이 실제 사람인지 확인하고 출근/퇴근 시간을 기록합니다.

- 대리 출근/퇴근 방지
- 근태 데이터 자동 수집 (향후 건강/보험 연계 데이터로 활용)

**⚠️ 단계별 도입 권장**:
1. **MVP/베타**: ML Kit Face Detection + 자체 블링크/헤드무브 챌린지 (묶음)
2. **운영**: AWS Rekognition Face Liveness 도입 ($0.015/세션)

---

## 2. 사용자 흐름

```
[출근 인증 버튼 클릭]
    ↓
[카메라 화면 진입]
    ↓
[ML Kit: 얼굴 감지 + 안내 메시지]
    ↓
[블링크 챌린지: "눈을 깜빡여 주세요"]
    ↓
[헤드무브 챌린지: "고개를 천천히 좌우로 돌려주세요"]
    ↓
[클라이언트 검증 통과]
    ↓
[Cloud Function: 출근 기록 저장]
    ↓
[Firestore: attendances 컬렉션 기록]
    ↓
[완료 알림]
```

---

## 3. DB 스키마 확장

### 3.1 attendances 컬렉션 (신규)

```
/attendances/{attendanceId}
```

| 필드 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `attendanceId` | string (문서ID) | 자체 UUID | `att_abc123` |
| `userId` | string | 사용자 ID | `user_abc` |
| `jobId` | string | 공고 ID | `KJJ_12345678` |
| `type` | string | 출근/퇴근 | `check_in` / `check_out` |
| `timestamp` | timestamp | 인증 시간 | 2026-05-14T09:00:00Z |
| `location` | geopoint | 인증 위치 | `{ lat: 37.5665, lng: 126.9780 }` |
| `livenessScore` | number | 생동성 점수 (0~1) | `0.92` |
| `method` | string | 인증 방식 | `mlkit` / `aws_rekognition` |
| `deviceInfo` | map | 기기 정보 | `{ os: "android", model: "SM-G991N" }` |
| `createdAt` | timestamp | 기록 일시 | 2026-05-14T09:00:00Z |

### 3.2 jobs 컬렉션 — 기존 필드

| 필드 | 설명 |
|---|---|
| `workLocation` | geopoint — 출퇴근 위치 대조용 |
| `locationTolerance` | number — 허용 오차 반경 (미터, 기본 500m) |

---

## 4. 구현 단계

### 4.1 Phase 1: ML Kit 기반 (묶음 MVP)

**Flutter 구현**:

```dart
// lib/screens/attendance/liveness_screen.dart

class LivenessScreen extends StatefulWidget {
  const LivenessScreen({super.key});

  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,  // 눈 개폐 확률 활성화
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  bool _blinkDetected = false;
  bool _headTurnDetected = false;
  double? _leftEyeOpen;
  double? _rightEyeOpen;

  Future<void> _processImage(InputImage image) async {
    final faces = await _faceDetector.processImage(image);
    if (faces.isEmpty) return;

    final face = faces.first;

    // 1. 블링크 감지
    final leftEye = face.leftEyeOpenProbability;
    final rightEye = face.rightEyeOpenProbability;
    if (leftEye != null && rightEye != null) {
      if (leftEye < 0.2 && rightEye < 0.2 && !_blinkDetected) {
        setState(() => _blinkDetected = true);
      }
    }

    // 2. 헤드 턴 감지 (Yaw 각도)
    final yaw = face.headEulerAngleY;
    if (yaw != null && yaw.abs() > 15 && !_headTurnDetected) {
      setState(() => _headTurnDetected = true);
    }

    // 3. 검증 완료
    if (_blinkDetected && _headTurnDetected) {
      _onLivenessSuccess();
    }
  }

  Future<void> _onLivenessSuccess() async {
    final position = await Geolocator.getCurrentPosition();
    
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('recordAttendance');
    
    await callable.call({
      'type': 'check_in',
      'location': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'method': 'mlkit',
    });

    if (mounted) {
      Navigator.pop(context, true);
    }
  }
}
```

**한계 명시**:
- ML Kit 단독으로는 **제품 수준의 liveness detection 불가**
- 사진 스푸핑(정지 사진): 부분적으로 탐지 가능 (블링크 + 헤드무브 패턴 분석)
- 비디오 재생 공격, 3D 마스크, 딥페이크: **방어 불가**
- 마케팅 문구: **"스마트 안면 확인"** ("100% 차단" 등의 과장 표현 금지)

### 4.2 Phase 2: AWS Rekognition Liveness (유료 전환 시)

**Cloud Function: `verifyLivenessAws`**

```typescript
// functions/src/attendance/verifyLivenessAws.ts

import { onCall } from 'firebase-functions/v2/https';
import { RekognitionClient, CreateFaceLivenessSessionCommand } from '@aws-sdk/client-rekognition';

const rekognition = new RekognitionClient({ 
  region: 'ap-northeast-2',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

export const verifyLivenessAws = onCall(
  {
    region: 'asia-northeast3',
    secrets: ['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY'],
  },
  async (request) => {
    const { userId, imageBase64 } = request.data;

    // 1. AWS Liveness 세션 생성
    const sessionCommand = new CreateFaceLivenessSessionCommand({
      KmsKeyId: process.env.AWS_KMS_KEY_ID,
    });
    const session = await rekognition.send(sessionCommand);

    // 2. 클라이언트에 세션 ID 반환 → 클라이언트가 AWS SDK로 직접 촬영/전송
    // 3. 결과 콜백 수신 후 검증
    
    return { 
      success: true, 
      sessionId: session.SessionId,
      // 실제 구현 시 AWS Liveness 결과 처리 추가
    };
  }
);
```

**AWS Rekognition Face Liveness 가격** (정정):
- **$0.015/세션** (첫 50만회)
- 다음 50만회: $0.0125/세션
- 100만회 이상: $0.01/세션
- Face Liveness 전용 묶음 티어 없음

---

## 5. Flutter 구현

### 5.1 위치 검증

```dart
// lib/providers/attendance_provider.dart

Future<bool> verifyLocation(String jobId, Position currentPosition) async {
  final jobDoc = await FirebaseFirestore.instance
      .collection('jobs')
      .doc(jobId)
      .get();
  
  final jobData = jobDoc.data()!;
  final workLocation = jobData['workLocation'] as GeoPoint;
  final tolerance = (jobData['locationTolerance'] ?? 500).toDouble();

  final distance = Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    workLocation.latitude,
    workLocation.longitude,
  );

  return distance <= tolerance;
}
```

### 5.2 출근 기록 Provider

```dart
@riverpod
class AttendanceNotifier extends _$AttendanceNotifier {
  @override
  FutureOr<void> build() => null;

  Future<bool> checkIn(String jobId) async {
    // 1. 위치 확인
    final position = await Geolocator.getCurrentPosition();
    final isNear = await verifyLocation(jobId, position);
    if (!isNear) throw Exception('근무지 근처에서만 인증 가능합니다');

    // 2. Liveness 화면 진입
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LivenessScreen()),
    );

    return result ?? false;
  }
}
```

---

## 6. 비용 예측

### Phase 1: ML Kit (묶음)

| 항목 | 비용 |
|---|---|
| ML Kit Face Detection | $0 (온디바이스) |
| Firestore 쓰기 | ~$0.05/월 (100명 기준) |
| **합계** | **~$0/월** |

### Phase 2: AWS Rekognition (1,000명)

| 항목 | 가정 | 월 비용 |
|---|---|---|
| 일 2회 × 22일 × 1,000명 | 44,000 세션 | **$660** |
| Firestore 쓰기 | 44,000회 | ~$6 |
| **합계** | | **~$666/월** |

---

## 7. 테스트 계획

### 7.1 MLKit 클라이언트 테스트

| 시나리오 | 기대 결과 |
|---|---|
| 정상 얼굴 + 블링크 + 헤드턴 | 인증 성공 |
| 정지 사진 | 블링크 실패 → 인증 거부 |
| 얼굴 없음 | "얼굴을 인식할 수 없습니다" 안내 |
| 어두운 환경 | "밝은 곳에서 시도해 주세요" 안내 |

### 7.2 위치 검증 테스트

| 현재 위치 | 근무지 | 허용 반경 | 결과 |
|---|---|---|---|
| 100m 떨어짐 | 서울역 | 500m | ✅ 통과 |
| 1km 떨어짐 | 서울역 | 500m | ❌ 거부 |

---

## 8. Definition of Done

### Phase 1 (MVP)
- [ ] ML Kit Face Detection 연동 (블링크 + 헤드무브 챌린지)
- [ ] `LivenessScreen` UI 구현 (카메라 프리뷰 + 안내 오버레이)
- [ ] 위치 검증 (Geolocator) 연동
- [ ] `recordAttendance` Cloud Function 구현
- [ ] `attendances` 컬렉션 기록 확인
- [ ] 마케팅 문구 "스마트 안면 확인"으로 통일 (과장 표현 금지)
- [ ] 단위 테스트 6개 이상 통과

### Phase 2 (운영)
- [ ] AWS Rekognition Liveness 연동
- [ ] AWS IAM + KMS 설정
- [ ] 비용 모니터링 알림 설정 (월 $500 기준)
- [ ] MLKit → AWS 단계적 전환 전략 수립
- [ ] `flutter analyze` 0 errors, 0 warnings
