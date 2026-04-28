# Page Work Request — Wiki Design Upgrade (2026 Modern Trends)

> **요청자**: User
> **담당**: OpenCode (implementer)
> **대상 파일**: `General/wiki.html` (단일 파일 수정 · `.github/workflows/pages.yml`은 변경 불필요)
> **트랙**: Page_Review (Non-PR work, infra/wiki 카테고리)
> **요청일**: 2026-04-25
> **예상 작업량**: 1.5~3시간 (디자인 토큰 → 컴포넌트 → 인터랙션 순)

---

## 1. Background & Goal

현재 wiki는 Miro-inspired 라이트 테마로 가독성은 좋지만 디자인 자체가 평이함. **2026 시점의 modern docs site 트렌드**(Linear, Vercel docs, shadcn/ui, Anthropic docs, Resend, Geist)를 참조해 wiki를 다음 수준으로 끌어올린다.

**Goal**: 사람용 위키가 "단순 문서 뷰어" → "프로덕트급 documentation site"로 격상.

**Non-Goal**: 콘텐츠 추가/수정. 기능 확장(검색 등). 거버넌스 변경. 이번 사이클은 **순수 시각·인터랙션 업그레이드**.

---

## 2. Design Direction

### 2-1. 참조 디자인
| Site | 가져올 요소 |
|---|---|
| **Linear** (linear.app/docs) | 타이포 hierarchy, generous whitespace, 1px hairline borders, ⌘K command palette |
| **Vercel docs** | 우측 TOC sidebar, scroll progress bar, anchor link buttons |
| **shadcn/ui docs** | OKLCH 컬러 팔레트, sharp 6px radius, dark/light dual mode |
| **Anthropic docs** | elegant 타이포(serif heading 대안), 절제된 색상 |
| **Resend** | subtle radial gradient background, frosted-glass sticky header |
| **Geist (Vercel)** | mono font 강조, 코드 블록 syntax highlighting |

### 2-2. 톤
- **Minimalist + Editorial**: 큰 hero 타이포, 충분한 line-height, 절제된 색상 (단일 accent + neutral 그레이 계조)
- **Sharp not Soft**: 16px → 6~8px radius, box-shadow 깊이 절제, hairline border 1px rgba(0,0,0,0.06)
- **Dual mode**: light/dark 토글 + system preference 자동 감지

---

## 3. Concrete Changes

### 3-1. Design Tokens (CSS Variables)

`:root`에 OKLCH 기반 dual-mode 토큰 도입:

```css
:root {
  /* Light mode (default) */
  --bg: oklch(99% 0 0);
  --surface: oklch(97.5% 0 0);
  --surface-2: oklch(95% 0 0);
  --border: oklch(90% 0 0);
  --border-strong: oklch(82% 0 0);
  --text: oklch(20% 0 0);
  --text-muted: oklch(50% 0 0);
  --text-faint: oklch(65% 0 0);
  --accent: oklch(58% 0.22 265);          /* indigo-500 등가 */
  --accent-hover: oklch(50% 0.24 265);
  --accent-soft: oklch(96% 0.04 265);
  --success: oklch(65% 0.18 145);
  --danger: oklch(60% 0.22 25);
  --warning: oklch(75% 0.16 75);

  /* Type scale (Major Third 1.25) */
  --fs-xs: 12px;
  --fs-sm: 13.5px;
  --fs-base: 15.5px;
  --fs-lg: 18px;
  --fs-xl: 22px;
  --fs-2xl: 28px;
  --fs-3xl: 36px;
  --fs-4xl: 48px;

  /* Radii */
  --r-sm: 4px;
  --r-md: 6px;
  --r-lg: 10px;
  --r-xl: 16px;

  /* Shadows (very subtle) */
  --shadow-xs: 0 1px 2px rgba(0,0,0,0.04);
  --shadow-sm: 0 2px 8px rgba(0,0,0,0.06);
  --shadow-md: 0 8px 24px rgba(0,0,0,0.08);

  /* Layout */
  --sidebar-w: 272px;
  --toc-w: 220px;
  --content-max: 740px;

  /* Motion */
  --ease: cubic-bezier(0.2, 0.8, 0.2, 1);
  --dur-fast: 120ms;
  --dur-base: 200ms;
}

[data-theme="dark"] {
  --bg: oklch(14% 0 0);
  --surface: oklch(18% 0 0);
  --surface-2: oklch(22% 0 0);
  --border: oklch(28% 0 0);
  --border-strong: oklch(38% 0 0);
  --text: oklch(96% 0 0);
  --text-muted: oklch(70% 0 0);
  --text-faint: oklch(55% 0 0);
  --accent: oklch(70% 0.20 265);
  --accent-hover: oklch(78% 0.22 265);
  --accent-soft: oklch(25% 0.08 265);
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    /* dark variables — same as [data-theme="dark"] */
  }
}
```

### 3-2. Typography

**Font stack**:
```html
<link rel="preconnect" href="https://rsms.me/" crossorigin>
<link rel="stylesheet" href="https://rsms.me/inter/inter.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&family=Noto+Sans+KR:wght@400;500;600;700&display=swap" rel="stylesheet">
```

```css
body {
  font-family: "Inter var", "Inter", "Noto Sans KR", -apple-system, sans-serif;
  font-feature-settings: "cv11", "ss01", "ss03";  /* Inter alternates */
  font-size: var(--fs-base);
  line-height: 1.65;
  letter-spacing: -0.005em;
  color: var(--text);
  background: var(--bg);
}

#content h1 {
  font-size: var(--fs-4xl);
  font-weight: 600;
  letter-spacing: -0.04em;
  line-height: 1.1;
  margin-bottom: 8px;
}
#content h2 {
  font-size: var(--fs-2xl);
  font-weight: 600;
  letter-spacing: -0.02em;
  margin: 56px 0 16px;
  scroll-margin-top: 80px;  /* anchor scroll 위치 보정 */
}
#content h3 {
  font-size: var(--fs-lg);
  font-weight: 600;
  margin: 32px 0 12px;
  scroll-margin-top: 80px;
}

#content code, #content pre {
  font-family: "JetBrains Mono", "SF Mono", Monaco, monospace;
  font-feature-settings: "calt", "ss01";
  font-size: 13.5px;
}
```

### 3-3. Background — Subtle Aurora

`body::before`로 고정 그라디언트 추가:
```css
body::before {
  content: '';
  position: fixed; inset: 0;
  background:
    radial-gradient(ellipse 60% 50% at 80% -10%, var(--accent-soft), transparent 60%),
    radial-gradient(ellipse 50% 40% at -10% 50%, var(--accent-soft), transparent 60%);
  opacity: 0.6;
  pointer-events: none;
  z-index: -1;
}
```

### 3-4. Layout — 3 Column

기존 sidebar(좌) + main(우) 2칼럼 → **sidebar(좌) + main(중) + TOC(우)** 3칼럼.

```html
<div id="layout">
  <aside id="sidebar">...</aside>
  <main id="main">
    <header id="topbar">  <!-- frosted glass sticky -->
      <button id="theme-toggle">🌓</button>
      <button id="cmd-trigger">⌘K Search</button>
    </header>
    <div id="content"></div>
  </main>
  <aside id="toc"></aside>  <!-- 자동 생성 TOC -->
</div>
```

```css
#topbar {
  position: sticky; top: 0; z-index: 10;
  display: flex; justify-content: flex-end; gap: 8px;
  padding: 12px 56px;
  backdrop-filter: blur(12px) saturate(180%);
  -webkit-backdrop-filter: blur(12px) saturate(180%);
  background: color-mix(in oklch, var(--bg) 75%, transparent);
  border-bottom: 1px solid var(--border);
}

#toc {
  width: var(--toc-w);
  position: sticky; top: 60px; align-self: flex-start;
  padding: 24px 16px;
  font-size: var(--fs-sm);
  color: var(--text-muted);
  max-height: calc(100vh - 80px);
  overflow-y: auto;
}
#toc a { display: block; padding: 4px 8px; border-radius: var(--r-sm); color: inherit; }
#toc a:hover { color: var(--accent); }
#toc a.active { color: var(--accent); font-weight: 600; border-left: 2px solid var(--accent); padding-left: 6px; }

@media (max-width: 1100px) { #toc { display: none; } }
@media (max-width: 768px) { #sidebar { display: none; } }
```

### 3-5. Sidebar — Linear-style minimal

기존 카드 구조(border-radius 16px + box-shadow) 폐기. **sharp + flat**으로:
```css
#sidebar {
  width: var(--sidebar-w);
  background: var(--surface);
  border-right: 1px solid var(--border);
  padding: 24px 0;
}
.nav-section { margin-bottom: 4px; padding: 0 12px; }
.nav-section-title {
  font-size: var(--fs-xs);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--text-faint);
  padding: 8px 12px;
}
.nav-link {
  display: flex; align-items: center; gap: 8px;
  padding: 6px 12px; border-radius: var(--r-md);
  font-size: var(--fs-sm);
  color: var(--text-muted);
  transition: color var(--dur-fast) var(--ease), background var(--dur-fast) var(--ease);
}
.nav-link:hover { color: var(--text); background: var(--surface-2); }
.nav-link.active {
  color: var(--accent);
  background: var(--accent-soft);
  font-weight: 600;
}
```

### 3-6. Code Blocks — Syntax Highlighting

**highlight.js 또는 Prism CDN 추가** (highlight.js 추천 — 자동 감지):

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.10.0/build/styles/github.min.css" media="(prefers-color-scheme: light)">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.10.0/build/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">
<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.10.0/build/highlight.min.js"></script>
```

`loadMarkdown`의 fetch 후 `marked.parse(text)` 실행 후:
```js
contentDiv.querySelectorAll('pre code').forEach((el) => hljs.highlightElement(el));
```

**Copy 버튼 추가**: 각 `<pre>`에 우상단 `<button class="copy-btn">📋</button>` 삽입:
```js
contentDiv.querySelectorAll('pre').forEach(pre => {
  const btn = document.createElement('button');
  btn.className = 'copy-btn';
  btn.textContent = 'Copy';
  btn.onclick = () => {
    navigator.clipboard.writeText(pre.querySelector('code').innerText);
    btn.textContent = 'Copied'; setTimeout(() => btn.textContent = 'Copy', 1200);
  };
  pre.style.position = 'relative';
  pre.appendChild(btn);
});
```

```css
pre { position: relative; padding: 20px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--r-lg); }
.copy-btn {
  position: absolute; top: 12px; right: 12px;
  padding: 4px 10px; font-size: 11px;
  border: 1px solid var(--border); background: var(--bg); border-radius: var(--r-sm);
  color: var(--text-muted); cursor: pointer; opacity: 0;
  transition: opacity var(--dur-fast) var(--ease);
}
pre:hover .copy-btn { opacity: 1; }
```

### 3-7. Anchor Links on Headings

각 h2/h3에 hover 시 보이는 `#` 앵커 버튼 (GitHub 스타일):
```js
contentDiv.querySelectorAll('h2, h3').forEach(h => {
  const id = h.textContent.toLowerCase().replace(/[^\w가-힣]+/g, '-').replace(/^-|-$/g, '');
  h.id = id;
  const link = document.createElement('a');
  link.href = `#${id}`;
  link.className = 'heading-anchor';
  link.textContent = '#';
  link.setAttribute('aria-label', `Permalink to ${h.textContent}`);
  h.appendChild(link);
});
```

```css
.heading-anchor {
  margin-left: 8px; opacity: 0; color: var(--text-faint);
  font-weight: 400; text-decoration: none;
  transition: opacity var(--dur-fast) var(--ease);
}
h2:hover .heading-anchor, h3:hover .heading-anchor { opacity: 1; }
```

### 3-8. Auto-generated TOC (우측 사이드바)

`loadMarkdown` 후:
```js
function buildTOC() {
  const toc = document.getElementById('toc');
  toc.innerHTML = '<div class="toc-title">On this page</div>';
  contentDiv.querySelectorAll('h2, h3').forEach(h => {
    const a = document.createElement('a');
    a.href = `#${h.id}`;
    a.textContent = h.textContent.replace(/#$/, '').trim();
    a.style.paddingLeft = h.tagName === 'H3' ? '20px' : '8px';
    a.dataset.target = h.id;
    toc.appendChild(a);
  });
  setupTOCObserver();
}

function setupTOCObserver() {
  const observer = new IntersectionObserver(entries => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        document.querySelectorAll('#toc a').forEach(a => a.classList.toggle('active', a.dataset.target === e.target.id));
      }
    });
  }, { rootMargin: '-20% 0px -70% 0px' });
  contentDiv.querySelectorAll('h2, h3').forEach(h => observer.observe(h));
}
```

### 3-9. Scroll Progress Bar

`#topbar` 하단에 1px progress:
```html
<div id="scroll-progress"></div>
```
```css
#scroll-progress {
  position: fixed; top: 0; left: 0; height: 2px;
  background: var(--accent);
  width: 0; z-index: 100;
  transition: width 50ms linear;
}
```
```js
window.addEventListener('scroll', () => {
  const main = document.getElementById('main');
  const pct = (main.scrollTop / (main.scrollHeight - main.clientHeight)) * 100;
  document.getElementById('scroll-progress').style.width = pct + '%';
}, { passive: true });
```

### 3-10. Theme Toggle + System Detection

```js
const themeToggle = document.getElementById('theme-toggle');
const stored = localStorage.getItem('theme');
if (stored) document.documentElement.setAttribute('data-theme', stored);

themeToggle.addEventListener('click', () => {
  const current = document.documentElement.getAttribute('data-theme')
    || (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  const next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('theme', next);
});
```

### 3-11. ⌘K Command Palette

간단한 modal 검색:
```html
<div id="cmd-modal" class="hidden">
  <div id="cmd-backdrop"></div>
  <div id="cmd-box">
    <input id="cmd-input" placeholder="Jump to page...">
    <div id="cmd-results"></div>
  </div>
</div>
```

```js
const allLinks = Array.from(document.querySelectorAll('.nav-link[data-md]')).map(a => ({
  title: a.textContent,
  path: a.dataset.md,
}));

document.addEventListener('keydown', (e) => {
  if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
    e.preventDefault();
    document.getElementById('cmd-modal').classList.remove('hidden');
    document.getElementById('cmd-input').focus();
  }
  if (e.key === 'Escape') document.getElementById('cmd-modal').classList.add('hidden');
});

document.getElementById('cmd-input').addEventListener('input', (e) => {
  const q = e.target.value.toLowerCase();
  const results = allLinks.filter(l => l.title.toLowerCase().includes(q)).slice(0, 8);
  document.getElementById('cmd-results').innerHTML = results.map(r =>
    `<div class="cmd-item" data-md="${r.path}">${r.title}<span>${r.path}</span></div>`
  ).join('');
});

document.getElementById('cmd-results').addEventListener('click', (e) => {
  const item = e.target.closest('.cmd-item');
  if (!item) return;
  loadMarkdown(item.dataset.md, true);
  document.getElementById('cmd-modal').classList.add('hidden');
});
```

```css
#cmd-modal { position: fixed; inset: 0; z-index: 50; display: flex; align-items: flex-start; justify-content: center; padding-top: 15vh; }
#cmd-modal.hidden { display: none; }
#cmd-backdrop { position: absolute; inset: 0; background: rgba(0,0,0,0.4); backdrop-filter: blur(4px); }
#cmd-box { position: relative; width: 560px; max-width: calc(100vw - 32px); background: var(--surface); border: 1px solid var(--border); border-radius: var(--r-xl); box-shadow: var(--shadow-md); overflow: hidden; }
#cmd-input { width: 100%; padding: 16px 20px; border: 0; outline: 0; font-size: 16px; background: transparent; color: var(--text); border-bottom: 1px solid var(--border); }
.cmd-item { padding: 10px 20px; font-size: var(--fs-sm); cursor: pointer; display: flex; justify-content: space-between; align-items: center; }
.cmd-item:hover { background: var(--surface-2); color: var(--accent); }
.cmd-item span { font-size: 11px; color: var(--text-faint); font-family: "JetBrains Mono", monospace; }
```

### 3-12. Skeleton Loader (Loading 상태)

`<div id="loading">Loading...</div>` → skeleton 라인 3개:
```html
<div id="loading">
  <div class="skel skel-h1"></div>
  <div class="skel skel-line"></div>
  <div class="skel skel-line short"></div>
</div>
```
```css
.skel { background: linear-gradient(90deg, var(--surface) 25%, var(--surface-2) 50%, var(--surface) 75%); background-size: 200% 100%; animation: shimmer 1.4s infinite; border-radius: var(--r-sm); }
.skel-h1 { height: 40px; width: 60%; margin-bottom: 24px; }
.skel-line { height: 14px; width: 100%; margin-bottom: 10px; }
.skel-line.short { width: 70%; }
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
```

### 3-13. View Transitions API (페이지 전환 부드럽게)

지원 브라우저(Chrome/Edge 111+, Safari 18+)에서 자동 fade transition:
```js
async function loadMarkdown(path, fromRoot) {
  // ... existing path resolution ...
  const update = () => {
    contentDiv.innerHTML = marked.parse(text);
    // ... rest of post-processing ...
  };
  if (document.startViewTransition) {
    document.startViewTransition(update);
  } else {
    update();
  }
}
```

---

## 4. Implementation Tasks (체크리스트)

OpenCode가 순서대로 처리하면 됨:

### Phase 1 — Tokens & Type (30분)
- [ ] OKLCH 토큰 + dark/light dual mode 도입 (3-1)
- [ ] Inter var + JetBrains Mono + Noto Sans KR 폰트 적용 (3-2)
- [ ] Aurora 배경 (3-3)
- [ ] 토글 버튼 자리만 마련 (실제 토글은 Phase 4)

### Phase 2 — Layout (30분)
- [ ] 3칼럼 grid 도입 — sidebar / main / toc (3-4)
- [ ] frosted-glass sticky topbar (3-4)
- [ ] sidebar 카드 → linear-style flat 변경 (3-5)
- [ ] 768/1100px responsive breakpoint

### Phase 3 — Content (30분)
- [ ] highlight.js 통합 + light/dark CSS (3-6)
- [ ] Copy 버튼 (3-6)
- [ ] heading anchor (3-7)
- [ ] 자동 TOC + IntersectionObserver active 추적 (3-8)

### Phase 4 — Interactions (45분)
- [ ] scroll progress bar (3-9)
- [ ] theme toggle + localStorage 저장 (3-10)
- [ ] ⌘K command palette (3-11)
- [ ] skeleton loader (3-12)
- [ ] View Transitions API 옵트인 (3-13)

### Phase 5 — Verification (15분)
- [ ] light/dark 두 모드에서 시각 검사
- [ ] 모바일 (768px 이하), 태블릿 (1100px 이하) 반응형 확인
- [ ] 마크다운 모든 요소 (h1~h3, ul/ol, table, blockquote, pre/code, hr, img) 스타일 확인
- [ ] internal `.md` 링크 + 외부 링크 + anchor 링크 모두 동작
- [ ] ⌘K → 검색 → 클릭 → 페이지 이동 flow
- [ ] 스크롤 시 TOC active 항목 갱신 확인

---

## 5. Acceptance Criteria

다음 모두 충족 시 완료:

1. **Dual Theme**: 라이트/다크 모드 토글 동작. system preference 자동 감지. localStorage 저장 영속성.
2. **3 Columns Desktop**: sidebar (272px) + main (max 740px) + toc (220px). 1100px 이하에서 toc 숨김. 768px 이하에서 sidebar 숨김.
3. **Frosted Topbar**: backdrop-blur가 적용된 sticky 헤더. 다크 모드에서도 자연스러운 투명도.
4. **Code Highlighting**: 모든 ```dart, ```yaml, ```bash, ```json 블록에 syntax highlighting. Copy 버튼 hover 시 노출.
5. **Heading Anchors**: h2/h3 hover 시 `#` 버튼 노출. 클릭 시 URL hash 변경 + 부드러운 스크롤.
6. **Auto TOC**: 현재 문서의 h2/h3로 TOC 자동 생성. 스크롤 위치 추적해서 active 항목 강조.
7. **Scroll Progress**: 페이지 상단 2px progress bar가 스크롤에 따라 변화.
8. **⌘K Palette**: ⌘K (Mac) / Ctrl+K (Windows/Linux) → 모달 → 입력 → 결과 클릭 → 페이지 이동.
9. **Skeleton Loader**: 마크다운 fetch 동안 "Loading..." 텍스트 대신 shimmer 애니메이션 라인 3개.
10. **Smooth Transitions**: View Transitions API 지원 브라우저에서 페이지 전환 시 자연스러운 fade.
11. **Zero Regressions**: 기존 기능(sidebar 클릭, 마크다운 internal `.md` 링크 nav, 상대 경로 처리, marked.js token API) 전부 동작.
12. **Performance**: 첫 페이지 로드 ≤ 800ms (Pages 기준, fonts/highlight.js CDN 포함).

---

## 6. Out of Scope (이번 사이클 제외)

- 검색의 fulltext indexing (sidebar 제목 검색만)
- Mermaid diagram support
- 다국어 (i18n)
- 댓글/리액션
- Auto-generated sidebar (hardcoded 유지)
- AGENTS.md 거버넌스 변경 (별도 트랙)
- 사이드바·TOC의 collapse/expand 기능 (필요하면 후속)

---

## 7. References (시각 참조)

OpenCode가 디자인 톤 잡을 때 참조 (스크린샷 못 보면 텍스트 설명만으로도 OK):

- **Linear Docs** (linear.app/docs) — 좌 sidebar minimal, 큰 타이포, generous whitespace, 1px hairline
- **Vercel Docs** (vercel.com/docs) — 우 TOC, scroll progress, 코드 블록 우상단 copy
- **shadcn/ui Docs** (ui.shadcn.com/docs) — OKLCH 컬러, 6px radius, sharp 쉐도우
- **Resend Docs** (resend.com/docs) — radial gradient bg, frosted topbar, mono font
- **Anthropic Docs** (docs.anthropic.com) — elegant restraint, large headings
- **Geist UI** (vercel.com/geist) — Inter + Geist Mono 조합 표준

---

## 8. 작업 후 보고

완료 시 다음 정보를 `docs/history/2026-04-25-wiki-design-upgrade.md`에 기록:

1. 적용한 토큰/컬러 팔레트 결정 사항 (e.g., accent hue 선택 이유)
2. CDN 의존성 (marked, highlight.js, fonts) 버전 pin 여부
3. 미해결/deferred 항목
4. 알려진 버그 또는 브라우저 호환성 노트
5. 스크린샷 (light/dark 각 1장) — 선택

리뷰는 사용자 확인 후 Claude/Gemini가 `docs/Page_Review/2026-04-25-wiki-design-upgrade-review_*.md`에 기록.

---

## 9. 참고 — Out of Scope이지만 미래 사이클 후보

- shiki SSR (빌드 타임 syntax highlighting → 더 빠름)
- algolia DocSearch 통합 (fulltext + ranking)
- Mermaid + KaTeX (다이어그램 + 수식)
- diff highlight (코드 블록의 +/- 라인)
- callout components (info/warn/danger box)
- table sort/filter
- multi-version 문서 지원

이번 사이클에서 위 항목 건드리지 말 것 — 토큰·인터랙션 안정화가 우선.

---

**요청 완료. OpenCode가 이 문서를 단일 source of truth로 삼아 작업하면 됨.**
