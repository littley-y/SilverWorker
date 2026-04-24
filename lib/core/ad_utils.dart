/// 키워드 추출 유틸리티
/// 루틴 이름에서 광고 매칭을 위한 핵심 키워드를 추출합니다.
String? extractKeyword(String name) {
  // 키워드 매핑 테이블 (Apple Style의 깔끔한 맥락 매칭)
  final keywords = {
    '샤워': ['샤워', '목욕', '씻기', '세안'],
    '커피': ['커피', '차', '음료', '녹차', '홍차', '라떼'],
    '메이크업': ['화장', '메이크업', '분장', '기초'],
    '운전': ['운전', '차', '이동', '주유'],
  };

  for (var entry in keywords.entries) {
    for (var val in entry.value) {
      if (name.contains(val)) return entry.key;
    }
  }

  return null;
}
