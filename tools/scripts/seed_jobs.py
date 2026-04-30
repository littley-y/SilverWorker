#!/usr/bin/env python3
"""
Generate 30 mock job postings for SilverWorkerNow (spec_03 path A).

Usage:
    python tools/scripts/seed_jobs.py --output tools/scripts/seed_jobs.json
    python tools/scripts/seed_jobs.py --upload
"""

from __future__ import annotations

import argparse
import json
import os
import random
import sys
from copy import deepcopy
from datetime import datetime, timedelta, timezone
from pathlib import Path

KST = timezone(timedelta(hours=9))

CATEGORY_TEMPLATES: dict[str, dict] = {
    "security_management": {
        "title_prefixes": [
            "아파트 경비원", "주차관리원", "시설 경비원", "공동주택 경비원",
            "주상복합 경비원", "빌딩 경비원", "학교 경비원", "병원 경비원",
            "물류센터 경비원", "공장 경비원",
        ],
        "descriptions": [
            "공동주택 출입 통제 및 순찰 업무",
            "주차장 관리 및 방문객 안내",
            "CCTV 모니터링 및 이상 상황 보고",
            "시설물 순찰 및 보안 점검",
            "출입 차량 통제 및 주차 유도",
        ],
        "benefits": ["중식 제공", "유니폼 지급", "주차 가능", "퇴직금", "4대보험"],
        "requirements": [
            "경비원 신임교육 이수자",
            "경비업무 경험자 우대",
            "장기근속 가능자",
            "책임감 강한 분",
            "운전 가능자 우대",
        ],
    },
    "cleaning": {
        "title_prefixes": [
            "아파트 청소원", "빌딩 청소원", "사무실 청소원", "병원 청소원",
            "학원 청소원", "상가 청소원",
        ],
        "descriptions": [
            "공용부 바닥 청소 및 쓰레기 분리수거",
            "계단 및 복도 청소",
            "화장실 청소 및 위생 관리",
            "사무실 내부 청소 및 정리",
            "엘리베이터 및 로비 청소",
        ],
        "benefits": ["중식 제공", "유니폼 지급", "교통비 지원", "4대보험"],
        "requirements": [
            "청소 경험자 우대",
            "성실하게 근무 가능한 분",
            "장기근속 가능자",
        ],
    },
    "simple_labor": {
        "title_prefixes": [
            "택배 상하차", "물류 분류원", "공장 생산직", "건설 현장 잡부",
            "농산물 선별원", "배달 보조",
        ],
        "descriptions": [
            "택배 물품 분류 및 상하차 업무",
            "공장 라인 보조 및 포장 업무",
            "건설 현장 자재 정리 및 청소",
            "물류센터 입출고 보조",
            "단순 반복 작업 및 포장",
        ],
        "benefits": ["중식 제공", "주휴수당", "퇴직금", "4대보험"],
        "requirements": [
            "체력에 자신 있는 분",
            "성실한 근무 태도",
            "장기근속 가능자",
        ],
    },
    "service": {
        "title_prefixes": [
            "주차 관리원", "매장 정리원", "카트 수거원", "주유원",
            "세차원", "안내 데스크",
        ],
        "descriptions": [
            "마트 카트 수거 및 정리",
            "주차장 정리 및 고객 안내",
            "주유 및 간단 세차 업무",
            "매장 내 정리 및 진열 보조",
            "방문객 안내 및 접수 업무",
        ],
        "benefits": ["중식 제공", "유니폼 지급", "주차 가능", "4대보험"],
        "requirements": [
            "친절한 응대 가능한 분",
            "장기근속 가능자",
            "서비스 경험자 우대",
        ],
    },
    "office_work": {
        "title_prefixes": [
            "문서 정리 보조", "데이터 입력", "전화 상담원", "사무 보조",
            "우편물 분류", "경리 보조",
        ],
        "descriptions": [
            "문서 정리 및 파일링 업무",
            "엑셀 데이터 입력 및 정리",
            "고객 전화 응대 및 상담",
            "사무실 행정 보조 업무",
            "우편물 분류 및 배분",
        ],
        "benefits": ["중식 제공", "교통비 지원", "퇴직금", "4대보험"],
        "requirements": [
            "기본 컴퓨터 활용 가능자",
            "꼼꼼하고 성실한 분",
            "장기근속 가능자",
        ],
    },
}

BADGE_POOLS: dict[str, list[list[str]]] = {
    "light": [
        ["sitting"],
        ["repetitive"],
        ["sitting", "repetitive"],
    ],
    "moderate": [
        ["standing"],
        ["standing", "outdoor"],
        ["standing", "repetitive"],
        ["outdoor"],
    ],
    "heavy": [
        ["standing", "heavy_lifting"],
        ["heavy_lifting", "outdoor"],
        ["heavy_lifting", "stairs"],
        ["standing", "heavy_lifting", "outdoor"],
        ["standing", "stairs"],
    ],
}

COMPANY_ADDRESSES: dict[str, list[str]] = {
    "11110": [
        "서울 종로구 세종대로 175",
        "서울 종로구 종로 1",
        "서울 종로구 창경궁로 254",
        "서울 종로구 삼일대로 458",
        "서울 종로구 자하문로 45",
        "서울 종로구 창의문로 12",
    ],
    "11140": [
        "서울 중구 을지로 66",
        "서울 중구 퇴계로 100",
        "서울 중구 남대문로 52",
        "서울 중구 다산로 128",
    ],
    "11170": [
        "서울 용산구 한강대로 203",
        "서울 용산구 이태원로 175",
        "서울 용산구 청파로 95",
        "서울 용산구 백범로 341",
    ],
}

OTHER_LOCATIONS = [
    ("11200", "서울 성동구 왕십리로 222"),
    ("11230", "서울 동대문구 왕산로 150"),
    ("11260", "서울 중랑구 망우로 353"),
]


def _random_date_in_future(days_min: int = 3, days_max: int = 60) -> str:
    delta = random.randint(days_min, days_max)
    dt = datetime.now(KST) + timedelta(days=delta)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def _random_employment_type() -> str:
    return random.choice(["part_time", "daily", "short_term", "full_time"])


def _random_salary(category: str) -> tuple[str, int]:
    if category in ("security_management", "cleaning"):
        amount = random.choice([1_800_000, 1_900_000, 2_000_000, 2_100_000, 2_200_000, 2_300_000])
        return ("monthly", amount)
    if category == "simple_labor":
        amount = random.choice([12_000, 13_000, 14_000, 15_000])
        return ("hourly", amount)
    if category == "service":
        amount = random.choice([1_500_000, 1_600_000, 1_800_000, 2_000_000])
        return ("monthly", amount)
    amount = random.choice([1_700_000, 1_800_000, 2_000_000, 2_200_000])
    return ("monthly", amount)


def generate_one(index: int, location_code: str, job_category: str, intensity: str) -> dict:
    template = CATEGORY_TEMPLATES[job_category]
    title_prefix = random.choice(template["title_prefixes"])
    company_suffixes = ["관리사무소", "관리단", "주식회사", "협동조합", "관리센터", "서비스센터"]
    company = f"{title_prefix} {index}호 {random.choice(company_suffixes)}"

    address = (
        random.choice(COMPANY_ADDRESSES.get(location_code, ["서울 OO구 OO로 123"]))
        if location_code != "기타"
        else OTHER_LOCATIONS[index % 3][1]
    )

    effective_location = location_code
    if location_code == "기타":
        effective_location = OTHER_LOCATIONS[index % 3][0]

    sal_type, sal_amount = _random_salary(job_category)

    return {
        "jobId": f"MOCK_{index:03d}",
        "source": "mock",
        "title": f"{title_prefix} 모집",
        "companyName": company,
        "companyAddress": address,
        "locationCode": effective_location,
        "jobCategory": job_category,
        "jobCategoryDetail": f"mock_{job_category}_{index:03d}",
        "employmentType": _random_employment_type(),
        "salaryType": sal_type,
        "salaryAmount": sal_amount,
        "workHours": "08:00 ~ 17:00 (휴게 1시간)" if random.random() > 0.3 else "09:00 ~ 18:00 (휴게 1시간)",
        "workDays": random.choice(["월~금", "월~토", "월~금 (격주 토요일)", "월~수"]),
        "workPeriod": random.choice(["3개월", "6개월", "12개월", "협의"]),
        "requirements": random.choice(template["requirements"]),
        "benefits": ",".join(random.sample(template["benefits"], k=min(2, len(template["benefits"])))),
        "description": random.choice(template["descriptions"]),
        "physicalIntensity": intensity,
        "physicalBadges": random.choice(BADGE_POOLS.get(intensity, BADGE_POOLS["moderate"])),
        "minAge": random.choice([55, 60, 65]),
        "maxAge": random.choice([70, 75, 80]),
        "deadline": _random_date_in_future(),
        "isActive": True,
        "rawData": {},
        "createdAt": "serverTimestamp",
        "updatedAt": "serverTimestamp",
    }


def generate_all(seed: int = 42) -> list[dict]:
    random.seed(seed)
    jobs: list[dict] = []
    idx = 1

    spec = [
        ("11110", "security_management", "moderate", 5),
        ("11110", "cleaning", "light", 4),
        ("11110", "simple_labor", "heavy", 3),
        ("11140", "security_management", "light", 4),
        ("11140", "service", "light", 4),
        ("11170", "security_management", "moderate", 4),
        ("11170", "office_work", "light", 3),
        ("기타", "security_management", "moderate", 1),
        ("기타", "cleaning", "light", 1),
        ("기타", "simple_labor", "heavy", 1),
    ]

    for location, category, intensity, count in spec:
        for _ in range(count):
            jobs.append(generate_one(idx, location, category, intensity))
            idx += 1

    return jobs


def upload_to_firestore(jobs: list[dict]) -> None:
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        print(
            "ERROR: firebase-admin not installed.\n"
            "  Run: pip install firebase-admin\n"
            "  Then set GOOGLE_APPLICATION_CREDENTIALS env var.",
            file=sys.stderr,
        )
        sys.exit(1)

    cred_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    if not cred_path:
        local_key = Path(__file__).parent / "serviceAccount.json"
        if local_key.exists():
            cred_path = str(local_key)

    if not cred_path:
        print(
            "ERROR: No service account key found.\n"
            "  Set GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json\n"
            "  Or place serviceAccount.json in tools/scripts/",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Using service account: {cred_path}")

    try:
        app = firebase_admin.get_app()
    except ValueError:
        cred = credentials.Certificate(cred_path)
        app = firebase_admin.initialize_app(cred)

    db = firestore.client(app=app)

    batch = db.batch()
    count = 0
    batch_size = 0
    MAX_BATCH = 500

    for job in jobs:
        doc_id = job["jobId"]
        doc_ref = db.collection("jobs").document(doc_id)

        data = deepcopy(job)
        data.pop("createdAt", None)
        data.pop("updatedAt", None)
        data.pop("jobId", None)

        if isinstance(data.get("deadline"), str):
            data["deadline"] = datetime.fromisoformat(
                data["deadline"].replace("Z", "+00:00")
            )
        data["createdAt"] = firestore.SERVER_TIMESTAMP
        data["updatedAt"] = firestore.SERVER_TIMESTAMP

        batch.set(doc_ref, data)
        count += 1
        batch_size += 1

        if batch_size >= MAX_BATCH:
            batch.commit()
            print(f"  Committed batch ({count} docs so far)")
            batch = db.batch()
            batch_size = 0

    if batch_size > 0:
        batch.commit()

    print(f"✓ Uploaded {count} mock jobs to Firestore /jobs collection.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate and optionally upload mock job postings."
    )
    parser.add_argument("--output", type=str, help="Path to write JSON file")
    parser.add_argument("--upload", action="store_true", help="Upload to Firestore")
    args = parser.parse_args()

    jobs = generate_all()
    print(f"Generated {len(jobs)} mock job postings.")

    output_path = args.output or str(Path(__file__).parent / "seed_jobs.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(jobs, f, ensure_ascii=False, indent=2)
    print(f"  → JSON saved to {output_path}")

    if args.upload:
        upload_to_firestore(jobs)


if __name__ == "__main__":
    main()
