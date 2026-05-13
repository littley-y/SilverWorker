import json
import random

# Realistic Korean company names by category and location
COMPANY_NAMES = {
    'security_management': [
        '종로타워 관리사무소', '강남파이낸스센터 보안팀', '롯데월드타워 주차팀',
        '삼성래미안 관리단', '현대아이파크 보안팀', '두산위브 관리사무소',
        '자이아파트 관리단', '힐스테이트 보안팀', 'e편한세상 관리사무소',
        '포레나 관리단', '더샵 보안팀', '래미안 관리사무소',
        '자이아파트 보안팀', '힐스테이트 관리단', 'e편한세상 보안팀',
        '포레나 관리사무소', '더샵 관리단', '래미안 보안팀',
        '자이아파트 관리사무소', '힐스테이트 주차팀', 'e편한세상 관리단',
        '포레나 보안팀', '더샵 관리사무소', '래미안 주차팀',
        '자이아파트 주차팀', '힐스테이트 관리사무소', 'e편한세상 주차팀',
        '포레나 주차팀', '더샵 주차팀', '래미안 관리단',
    ],
    'cleaning': [
        '서울아산병원 시설팀', '삼성서울병원 청소팀', '세브란스병원 위생팀',
        '서울대병원 시설관리팀', '고려대병원 청소팀', '연세세브란스 위생팀',
        '삼성래미안 청소팀', '현대아이파크 시설팀', '두산위브 청소팀',
        '자이아파트 청소팀', '힐스테이트 시설팀', 'e편한세상 청소팀',
        '포레나 청소팀', '더샵 시설팀', '래미안 청소팀',
        '종로타워 청소팀', '강남파이낸스센터 시설팀', '롯데월드타워 청소팀',
        '서울아산병원 청소팀', '삼성서울병원 시설팀', '세브란스병원 청소팀',
        '서울대병원 청소팀', '고려대병원 시설팀', '연세세브란스 청소팀',
        '삼성래미안 시설팀', '현대아이파크 청소팀', '두산위브 시설팀',
        '자이아파트 시설팀', '힐스테이트 청소팀',
    ],
    'simple_labor': [
        '쿠팡 물류센터', '마켓컬리 물류센터', 'SSG닷컴 물류센터',
        '이마트 물류센터', '롯데마트 물류센터', '홈플러스 물류센터',
        'CJ대한통운 물류센터', '로젠택배 물류센터', '한진택배 물류센터',
        '우체국택배 물류센터', '쿠팡 로켓배송 센터', '마켓컬리 새벽배송 센터',
        'SSG닷컴 배송센터', '이마트 트레이더스 센터', '롯데마트 물류팀',
        '홈플러스 배송센터', 'CJ대한통운 배송팀', '로젠택배 배송센터',
        '한진택배 배송팀', '우체국택배 배송센터', '쿠팡 프레시 센터',
        '마켓컬리 프레시 센터', 'SSG닷컴 프레시 센터', '이마트 에브리데이 센터',
        '롯데마트 슈퍼 센터', '홈플러스 익스프레스 센터', 'CJ대한통운 택배팀',
        '로젠택배 택배팀', '한진택배 택배팀',
    ],
    'service': [
        'GS25 편의점', 'CU 편의점', '7-ELEVEN 편의점',
        '미니스톱 편의점', '이마트24 편의점', '롯데리아 매장',
        '맥도날드 매장', '버거킹 매장', 'KFC 매장',
        '스타벅스 매장', '투썸플레이스 매장', '이디야커피 매장',
        '파리바게뜨 매장', '뚜레쥬르 매장', '던킨도너츠 매장',
        '베스킨라빈스 매장', '설빙 매장', '공차 매장',
        '공차 매장', 'GS25 주유소', 'SK주유소',
        '현대오일뱅크 주유소', 'S-OIL 주유소', 'GS칼텍스 주유소',
        'E1 주유소', 'SK에너지 주유소', '현대오일뱅크 주유소',
        'S-OIL 주유소', 'GS칼텍스 주유소', 'E1 주유소',
    ],
    'office_work': [
        '삼성전자 사무실', 'LG전자 사무실', '현대자동차 사무실',
        'SK하이닉스 사무실', 'POSCO 사무실', 'KT 사무실',
        'LG유플러스 사무실', 'SK텔레콤 사무실', '한국전력 사무실',
        '한화그룹 사무실', '롯데그룹 사무실', '신한은행 사무실',
        'KB국민은행 사무실', '우리은행 사무실', '하나은행 사무실',
        'NH농협은행 사무실', 'IBK기업은행 사무실', 'SC제일은행 사무실',
        '시티은행 사무실', '현대카드 사무실', '삼성카드 사무실',
        'KB카드 사무실', '롯데카드 사무실', 'BC카드 사무실',
        '신한카드 사무실', '하나카드 사무실', '우리카드 사무실',
        '삼성생명 사무실', '한화손핵보험 사무실', 'DB손핵보험 사무실',
    ],
}

# Title templates by category (without "모집")
TITLE_TEMPLATES = {
    'security_management': [
        '빌딩 경비원', '공장 경비원', '주상복합 경비원', '공동주택 경비원',
        '주차관리원', '시설 경비원', '병원 경비원', '아파트 경비원',
        '오피스텔 경비원', '상가 경비원', '물류센터 경비원', '학교 경비원',
    ],
    'cleaning': [
        '빌딩 청소원', '공장 청소원', '아파트 청소원', '병원 청소원',
        '학교 청소원', '상가 청소원', '오피스텔 청소원', '주상복합 청소원',
        '물류센터 청소원', '주차장 청소원', '화장실 청소원', '식당 청소원',
    ],
    'simple_labor': [
        '공장 생산직', '물류 분류원', '택배 상하차', '창고 정리원',
        '포장 보조원', '이삿짐 보조원', '공사장 보조원', '농장 보조원',
        '식당 주방보조', '마트 진열원', '공원 환경정리원', '재활용 분류원',
    ],
    'service': [
        '매장 정리원', '카트 수거원', '안내 데스크', '주유원',
        '주차 안내원', '매장 보조원', '식당 서빙', '편의점 직원',
        '마트 계산원', '매장 판매원', '주차 도우미', '배달 보조원',
    ],
    'office_work': [
        '데이터 입력', '경리 보조', '서류 정리원', '전화 상담원',
        '우편물 분류원', '문서 보조원', '행정 보조원', '접수 담당원',
        '자료 입력원', '사무보조원', '안내 전화원', '출납 보조원',
    ],
}

def update_seed_data():
    with open('seed_jobs.json', 'r', encoding='utf-8') as f:
        jobs = json.load(f)

    used_names = set()
    used_titles = set()

    for job in jobs:
        category = job['jobCategory']

        # Update company name
        candidates = COMPANY_NAMES.get(category, ['알 수 없는 회사'])
        name = None
        for _ in range(100):
            candidate = random.choice(candidates)
            if candidate not in used_names:
                name = candidate
                used_names.add(name)
                break
        if name is None:
            name = f"{random.choice(candidates)} {random.randint(1, 99)}"
        job['companyName'] = name

        # Update title (remove "모집")
        title_templates = TITLE_TEMPLATES.get(category, [job['title'].replace(' 모집', '')])
        title = None
        for _ in range(100):
            candidate = random.choice(title_templates)
            if candidate not in used_titles:
                title = candidate
                used_titles.add(title)
                break
        if title is None:
            title = f"{random.choice(title_templates)} {random.randint(1, 99)}"
        job['title'] = title

        # Add workHoursPerDay (8 hours for most jobs)
        work_hours = job.get('workHours', '')
        if '09:00 ~ 18:00' in work_hours or '08:00 ~ 17:00' in work_hours:
            job['workHoursPerDay'] = 8
        elif '10:00 ~ 16:00' in work_hours:
            job['workHoursPerDay'] = 6
        elif '09:00 ~ 15:00' in work_hours:
            job['workHoursPerDay'] = 6
        else:
            job['workHoursPerDay'] = 8

    with open('seed_jobs.json', 'w', encoding='utf-8') as f:
        json.dump(jobs, f, ensure_ascii=False, indent=2)

    print(f"Updated {len(jobs)} jobs")
    print("Sample names:")
    for job in jobs[:5]:
        print(f"  {job['title']} @ {job['companyName']}")

if __name__ == '__main__':
    update_seed_data()
