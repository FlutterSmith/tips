// All client-side behaviour. Every feature is progressive: the pages are
// complete without this script.

const $ = <T extends Element = HTMLElement>(s: string, r: ParentNode = document) => r.querySelector<T>(s);
const $$ = <T extends Element = HTMLElement>(s: string, r: ParentNode = document) => [...r.querySelectorAll<T>(s)];
const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
const base = document.documentElement.dataset.base ?? '/';

function store(key: string, value?: string): string | null {
  try {
    if (value === undefined) return localStorage.getItem(key);
    localStorage.setItem(key, value);
  } catch {
    // Storage can be blocked (private mode); the feature still works per page.
  }
  return null;
}

/* ---------- toast ---------- */
let toastTimer: number | undefined;
function toast(html: string) {
  const el = $('#toast');
  if (!el) return;
  el.innerHTML = html;
  el.classList.add('on');
  clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => el.classList.remove('on'), 3200);
}

/* ---------- theme: System → Light → Dark ---------- */
const THEMES = ['system', 'light', 'dark'] as const;
type Theme = (typeof THEMES)[number];
function applyTheme(theme: Theme) {
  const root = document.documentElement;
  if (theme === 'system') root.removeAttribute('data-theme');
  else root.setAttribute('data-theme', theme);
  const label = $('#theme-label');
  if (label) label.textContent = theme[0].toUpperCase() + theme.slice(1);
  $('#theme')?.setAttribute('aria-label', `Theme: ${theme}. Change theme`);
}
function cycleTheme() {
  const current = (store('fs-theme') as Theme | null) ?? 'system';
  const next = THEMES[(THEMES.indexOf(current) + 1) % THEMES.length];
  store('fs-theme', next);
  applyTheme(next);
}

/* ---------- debug paint ---------- */
function measurePaint() {
  if (!document.body.classList.contains('paint')) return;
  for (const el of $$('.pb')) {
    const r = el.getBoundingClientRect();
    el.dataset.size = `${Math.round(r.width)} × ${Math.round(r.height)}`;
  }
}
function togglePaint() {
  const on = document.body.classList.toggle('paint');
  $('#paint')?.setAttribute('aria-pressed', String(on));
  measurePaint();
  if (on) toast('This is what <code>debugPaintSizeEnabled = true</code> does to a Flutter app.');
}

/* ---------- annotated code panels ---------- */
interface Note {
  line: number;
  text: string;
}

// Seeded jitter keeps arrows hand-drawn but identical between renders.
function rng(seed: number) {
  let s = seed % 2147483647 || 1;
  return () => (s = (s * 16807) % 2147483647) / 2147483647;
}

function arrowPaths(x0: number, y0: number, x1: number, y1: number, seed: number): [string, string] {
  const r = rng(seed * 97 + 13);
  const cx = (x0 + x1) / 2;
  const cy = Math.min(y0, y1) - 26 - Math.abs(y0 - y1) * 0.2;
  const pts: [number, number][] = [];
  for (let i = 0; i <= 18; i++) {
    const t = i / 18;
    const u = 1 - t;
    const w = Math.sin(Math.PI * t) * 1.3;
    pts.push([
      u * u * x0 + 2 * u * t * cx + t * t * x1 + (r() - 0.5) * w,
      u * u * y0 + 2 * u * t * cy + t * t * y1 + (r() - 0.5) * w,
    ]);
  }
  const d = pts.map(([x, y], i) => `${i ? 'L' : 'M'}${x.toFixed(1)} ${y.toFixed(1)}`).join(' ');
  const [ax, ay] = pts[pts.length - 3];
  const ang = Math.atan2(y1 - ay, x1 - ax);
  const head = (a: number) =>
    `${(x1 - 9 * Math.cos(ang + a)).toFixed(1)} ${(y1 - 9 * Math.sin(ang + a)).toFixed(1)}`;
  return [d, `M${head(0.5)} L${x1.toFixed(1)} ${y1.toFixed(1)} L${head(-0.5)}`];
}

function layoutPanel(panel: HTMLElement, animate: boolean) {
  const notes: Note[] = JSON.parse(panel.dataset.notes ?? '[]');
  const wide = panel.clientWidth >= 600 && notes.length > 0;
  panel.classList.toggle('lane-on', wide);
  panel.classList.toggle('compact', panel.clientWidth < 600);
  const svg = $<SVGSVGElement>('svg.arrows', panel);
  const lane = $('.lane', panel);
  if (!svg || !lane) return;
  svg.replaceChildren();
  if (!wide) return;

  if (lane.childElementCount !== notes.length) {
    lane.replaceChildren(
      ...notes.map((n, i) => {
        const div = document.createElement('div');
        div.className = 'note';
        div.dataset.n = String(i);
        div.textContent = n.text;
        div.addEventListener('mouseenter', () => focusNote(panel, i, true));
        div.addEventListener('mouseleave', () => focusNote(panel, i, false));
        return div;
      }),
    );
  }

  const lines = $$('pre.code .line', panel);
  const body = $('.panel-body', panel)!.getBoundingClientRect();
  const laneBox = lane.getBoundingClientRect();
  let lastBottom = -Infinity;
  const seedBase = [...(panel.dataset.notes ?? '')].reduce((a, c) => a + c.charCodeAt(0), 0);

  $$('.note', lane).forEach((note, i) => {
    const line = lines[notes[i].line];
    if (!line) return;
    const lr = line.getBoundingClientRect();
    const range = document.createRange();
    range.selectNodeContents(line);
    const textRight = Math.max(...[...range.getClientRects()].map((r) => r.right), lr.left + 60);
    let top = lr.top + lr.height / 2 - body.top - 11;
    top = Math.max(top, lastBottom + 10);
    note.style.top = `${top}px`;
    lastBottom = top + note.offsetHeight;

    const x0 = laneBox.left - body.left + 12;
    const y0 = top + 12;
    const x1 = Math.min(textRight - body.left + 12, laneBox.left - body.left - 28);
    const y1 = lr.top + lr.height / 2 - body.top;
    arrowPaths(x0, y0, x1, y1, seedBase + i).forEach((d, k) => {
      const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('d', d);
      path.setAttribute('pathLength', '1');
      path.dataset.n = String(i);
      if (animate && !reduced) {
        path.style.strokeDasharray = '1';
        path.style.strokeDashoffset = '1';
        path.style.transitionDelay = `${i * 140 + k * 380}ms`;
        requestAnimationFrame(() => requestAnimationFrame(() => (path.style.strokeDashoffset = '0')));
      }
      svg.appendChild(path);
    });
  });
}

function focusNote(panel: HTMLElement, n: number, on: boolean) {
  const notes: Note[] = JSON.parse(panel.dataset.notes ?? '[]');
  $$('pre.code .line', panel)[notes[n]?.line]?.classList.toggle('hl', on);
  $$(`svg.arrows path[data-n="${n}"]`, panel).forEach((p) => p.classList.toggle('on', on));
  $(`.notes-list li[data-n="${n}"]`, panel)?.classList.toggle('on', on);
}

function panelText(panel: HTMLElement) {
  return $$('pre.code .line', panel)
    .map((line) => {
      const clone = line.cloneNode(true) as HTMLElement;
      clone.querySelectorAll('.mk').forEach((m) => m.remove());
      return clone.textContent ?? '';
    })
    .join('\n');
}

async function copyPanel(panel: HTMLElement, button: HTMLElement) {
  const label = $('span', button);
  try {
    await navigator.clipboard.writeText(panelText(panel));
    if (label) label.textContent = 'Copied';
  } catch {
    const range = document.createRange();
    range.selectNodeContents($('pre.code', panel)!);
    const sel = getSelection();
    sel?.removeAllRanges();
    sel?.addRange(range);
    if (label) label.textContent = 'Selected';
  }
  setTimeout(() => label && (label.textContent = 'Copy'), 1400);
}

function initPanels(root: ParentNode = document) {
  const observer = new ResizeObserver((entries) => {
    for (const e of entries) layoutPanel(e.target as HTMLElement, false);
  });
  for (const panel of $$('.panel', root)) {
    if (panel.dataset.ready) continue;
    panel.dataset.ready = '1';
    const r = panel.getBoundingClientRect();
    const visible = r.top < innerHeight && r.bottom > 0 && panel.offsetParent !== null;
    layoutPanel(panel, visible);
    observer.observe(panel);
    $$('.mk', panel).forEach((m) =>
      m.addEventListener('click', () => {
        const n = Number(m.dataset.n);
        focusNote(panel, n, true);
        setTimeout(() => focusNote(panel, n, false), 1800);
      }),
    );
  }
}

/* ---------- home: featured snippets ---------- */
function shuffleFeatured() {
  const box = $('.featured');
  if (!box) return;
  const panels = $$('.panel', box);
  if (panels.length < 2) return;
  const first = panels[0];
  const pick = 1 + Math.floor(Math.random() * (panels.length - 1));
  const next = panels[pick];
  box.prepend(next);
  box.append(first);
  next.dataset.ready = '';
  initPanels(box);
  layoutPanel(next, true);
}

/* ---------- random tip ---------- */
function randomTip() {
  const slugs: string[] = JSON.parse($('#tip-slugs')?.textContent ?? '[]');
  if (!slugs.length) return;
  const current = document.documentElement.dataset.slug;
  const pool = slugs.filter((s) => s !== current);
  location.href = `${base}tips/${pool[Math.floor(Math.random() * pool.length)]}/`;
}

/* ---------- search (Pagefind) ---------- */
interface PagefindResult {
  data: () => Promise<{ url: string; excerpt: string; meta: Record<string, string> }>;
}
interface Pagefind {
  search: (q: string) => Promise<{ results: PagefindResult[] }>;
}
let pagefind: Pagefind | null | undefined;
async function loadPagefind(): Promise<Pagefind | null> {
  if (pagefind !== undefined) return pagefind;
  try {
    const path = `${base}pagefind/pagefind.js`;
    pagefind = (await import(/* @vite-ignore */ path)) as Pagefind;
  } catch {
    pagefind = null;
  }
  return pagefind;
}

let selected = 0;
let searchSeq = 0;
async function runSearch() {
  const input = $<HTMLInputElement>('#q')!;
  const list = $('#results')!;
  const term = input.value.trim();
  const seq = ++searchSeq;
  if (!term) {
    list.innerHTML = '<li class="empty">Type a title, an idea or an API name like <code class="i">requireValue</code>.</li>';
    return;
  }
  const pf = await loadPagefind();
  if (!pf) {
    list.innerHTML = '<li class="empty">Search runs on the built site. Run <code class="i">npm run build</code> and preview it.</li>';
    return;
  }
  const { results } = await pf.search(term);
  const data = await Promise.all(results.slice(0, 8).map((r) => r.data()));
  if (seq !== searchSeq) return;
  selected = 0;
  if (!data.length) {
    const safe = term.replace(/[<>&]/g, '');
    list.innerHTML = `<li class="empty">Nothing for “${safe}”. Try an API name like <code class="i">ref.listen</code>.</li>`;
    return;
  }
  list.innerHTML = data
    .map(
      (d, i) =>
        `<li><a href="${d.url}" class="${i === 0 ? 'sel' : ''}"><span class="n">${d.meta.number ?? ''}</span>` +
        `<span class="t">${d.meta.title ?? ''}</span><span class="c">${d.excerpt}</span></a></li>`,
    )
    .join('');
}

function openSearch() {
  const bg = $('#pal')!;
  bg.hidden = false;
  const input = $<HTMLInputElement>('#q')!;
  input.value = '';
  void runSearch();
  input.focus();
  void loadPagefind();
}
function closeSearch() {
  $('#pal')!.hidden = true;
}
function openHelp() {
  $('#help')!.hidden = false;
  $<HTMLButtonElement>('#help button')?.focus();
}

/* ---------- boot ---------- */
function boot() {
  applyTheme((store('fs-theme') as Theme | null) ?? 'system');
  $('#theme')?.addEventListener('click', cycleTheme);
  $('#paint')?.addEventListener('click', togglePaint);
  $('#open-search')?.addEventListener('click', openSearch);
  $$('[data-random]').forEach((b) => b.addEventListener('click', randomTip));
  $$('[data-shuffle]').forEach((b) => b.addEventListener('click', shuffleFeatured));
  addEventListener('resize', measurePaint);

  document.addEventListener('click', (e) => {
    const target = e.target as HTMLElement;
    const copy = target.closest<HTMLElement>('[data-copy]');
    if (copy) void copyPanel(copy.closest('.panel')!, copy);
    if (target.id === 'pal' || target.closest('#results a')) closeSearch();
    if (target.id === 'help' || target.closest('[data-close-help]')) $('#help')!.hidden = true;
  });

  let debounce: number | undefined;
  $('#q')?.addEventListener('input', () => {
    clearTimeout(debounce);
    debounce = window.setTimeout(runSearch, 120);
  });
  $('#q')?.addEventListener('keydown', (e) => {
    const items = $$<HTMLAnchorElement>('#results a');
    if ((e.key === 'ArrowDown' || e.key === 'ArrowUp') && items.length) {
      e.preventDefault();
      items[selected]?.classList.remove('sel');
      selected = (selected + (e.key === 'ArrowDown' ? 1 : items.length - 1)) % items.length;
      items[selected].classList.add('sel');
      items[selected].scrollIntoView({ block: 'nearest' });
    } else if (e.key === 'Enter' && items[selected]) {
      location.href = items[selected].href;
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (!$('#pal')!.hidden) return closeSearch();
      if (!$('#help')!.hidden) return ($('#help')!.hidden = true);
    }
    const t = e.target as HTMLElement;
    if (t.closest('input, textarea, select, [contenteditable]') || e.metaKey || e.ctrlKey || e.altKey) return;
    const link = (rel: string) => $<HTMLAnchorElement>(`a[data-rel="${rel}"]`);
    switch (e.key) {
      case '/':
        e.preventDefault();
        openSearch();
        break;
      case 'r':
        randomTip();
        break;
      case 'p':
        togglePaint();
        break;
      case 't':
        cycleTheme();
        break;
      case 'c': {
        const btn = $<HTMLElement>('main .panel [data-copy]');
        if (btn) void copyPanel(btn.closest('.panel')!, btn);
        break;
      }
      case '?':
        openHelp();
        break;
      case 'ArrowLeft':
        if (link('prev')) location.href = link('prev')!.href;
        break;
      case 'ArrowRight':
        if (link('next')) location.href = link('next')!.href;
        break;
    }
  });

  const progress = $('#progress');
  if (progress && document.documentElement.dataset.slug) {
    addEventListener(
      'scroll',
      () => {
        const h = document.documentElement.scrollHeight - innerHeight;
        progress.style.width = `${h > 0 ? (scrollY / h) * 100 : 0}%`;
      },
      { passive: true },
    );
  }

  for (const row of $$('.dbg')) {
    const measure = () => {
      const r = row.getBoundingClientRect();
      row.dataset.size = `${Math.round(r.width)} × ${Math.round(r.height)}`;
    };
    row.addEventListener('mouseenter', measure);
    row.addEventListener('focus', measure);
  }

  initPanels();
  document.fonts?.ready.then(() => $$('.panel.lane-on').forEach((p) => layoutPanel(p, false)));
}

boot();
