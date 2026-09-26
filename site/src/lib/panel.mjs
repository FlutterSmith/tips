// Builds the annotated code panel (the site's signature component) as hast.
// Used by the Markdown pipeline and by pages that show a single snippet, so
// both render identical markup.
import { createHighlighter } from 'shiki';

/** Syntax colours tuned for the ink panel (same in light and dark mode). */
const theme = {
  name: 'fs-panel',
  type: 'dark',
  colors: { 'editor.background': '#00000000', 'editor.foreground': '#DCE3EE' },
  tokenColors: [
    { settings: { foreground: '#DCE3EE' } },
    { scope: ['comment', 'punctuation.definition.comment'], settings: { foreground: '#7D8AA3', fontStyle: 'italic' } },
    { scope: ['keyword', 'storage', 'storage.type', 'storage.modifier', 'keyword.control', 'variable.language', 'constant.language'], settings: { foreground: '#63D3EE' } },
    { scope: ['keyword.operator', 'punctuation'], settings: { foreground: '#AEB9CB' } },
    { scope: ['support.class', 'entity.name.type', 'entity.name.class', 'support.type', 'storage.type.primitive', 'storage.type.annotation'], settings: { foreground: '#B9A7FF' } },
    { scope: ['entity.name.function', 'support.function', 'meta.function-call'], settings: { foreground: '#F2E6B8' } },
    { scope: ['string', 'string.interpolated', 'punctuation.definition.string'], settings: { foreground: '#9ED99A' } },
    { scope: ['constant.numeric', 'constant.character'], settings: { foreground: '#FFB38A' } },
    { scope: ['entity.name.tag', 'entity.other.attribute-name', 'support.type.property-name'], settings: { foreground: '#63D3EE' } },
  ],
};

const LANGS = ['dart', 'yaml', 'shellscript', 'json', 'diff', 'html', 'css', 'javascript'];
const ALIASES = { sh: 'shellscript', bash: 'shellscript', shell: 'shellscript', console: 'shellscript' };

let highlighterPromise;
function highlighter() {
  highlighterPromise ??= createHighlighter({ themes: [theme], langs: LANGS });
  return highlighterPromise;
}

const NOTE_LINE = /^\s*\/\/\s*@note\s+(.+?)\s*$/;
const NOTE_TRAILING = /^(.*?\S)\s*\/\/\s*@note\s+(.+?)\s*$/;

/**
 * Removes `// @note` comments from [code]. A comment on its own line
 * annotates the next line; a trailing one annotates its own line.
 * @param {string} code
 */
export function extractNotes(code) {
  const out = [];
  const notes = [];
  let pending = [];
  for (const raw of code.replace(/\n$/, '').split('\n')) {
    const own = raw.match(NOTE_LINE);
    if (own) {
      pending.push(own[1]);
      continue;
    }
    const trailing = raw.match(NOTE_TRAILING);
    out.push(trailing ? trailing[1] : raw);
    const line = out.length - 1;
    for (const text of pending) notes.push({ line, text });
    if (trailing) notes.push({ line, text: trailing[2] });
    pending = [];
  }
  return { code: out.join('\n'), notes };
}

/** Parses `key="value"` pairs from a fence's info string. */
export function parseMeta(meta = '') {
  const attrs = {};
  for (const m of meta.matchAll(/(\w+)="([^"]*)"/g)) attrs[m[1]] = m[2];
  return attrs;
}

const el = (tagName, properties = {}, children = []) => ({ type: 'element', tagName, properties, children });
const text = (value) => ({ type: 'text', value });

const COPY_ICON = el('svg', { viewBox: '0 0 16 16', ariaHidden: 'true', className: ['icon-copy'] }, [
  el('rect', { x: 5, y: 5, width: 9, height: 9, rx: 1, fill: 'none', stroke: 'currentColor', strokeWidth: 1.4 }),
  el('path', { d: 'M3 11V3a1 1 0 0 1 1-1h7', fill: 'none', stroke: 'currentColor', strokeWidth: 1.4 }),
]);

/**
 * @param {{ code: string, lang?: string, meta?: string }} input
 * @returns {Promise<import('hast').Element>}
 */
export async function buildPanel({ code, lang = 'text', meta = '' }) {
  const attrs = parseMeta(meta);
  const language = ALIASES[lang] ?? lang;
  const isDart = language === 'dart';
  const { code: clean, notes } = isDart ? extractNotes(code) : { code: code.replace(/\n$/, ''), notes: [] };
  const kind = 'dont' in attrs ? 'dont' : 'do' in attrs ? 'do' : 'plain';

  const hl = await highlighter();
  const supported = hl.getLoadedLanguages().includes(language);
  const root = hl.codeToHast(clean, {
    lang: supported ? language : 'text',
    theme: 'fs-panel',
    transformers: [
      {
        line(node, lineNumber) {
          const here = notes.map((n, i) => ({ ...n, i })).filter((n) => n.line === lineNumber - 1);
          for (const n of here) {
            node.children.push(
              el('button', { type: 'button', className: ['mk'], dataN: n.i, ariaLabel: `Note ${n.i + 1}: ${n.text}` }, [text(String(n.i + 1))]),
            );
          }
        },
      },
    ],
  });
  const pre = root.children.find((c) => c.type === 'element' && c.tagName === 'pre');
  pre.properties = { className: ['code'], tabIndex: 0, dataLang: language };

  const head =
    kind === 'plain'
      ? [
          el('span', { className: ['file'] }, [text(attrs.file ?? language)]),
          ...(attrs.file && isDart
            ? [el('span', { className: ['ok'], title: 'This code is analyzed and tested in CI' }, [text('✓'), el('span', { className: ['okt'] }, [text(' analyzed · tested')])])]
            : []),
        ]
      : [el('span', { className: ['tag'] }, [text(kind === 'dont' ? '✗ Avoid' : '✓ Prefer')])];

  const children = [
    el('div', { className: ['panel-head'], dataPagefindIgnore: '' }, [
      ...head,
      el('span', { className: ['spacer'] }),
      el('button', { type: 'button', className: ['copy'], dataCopy: '' }, [COPY_ICON, el('span', {}, [text('Copy')])]),
    ]),
    el('div', { className: ['panel-body'] }, [
      pre,
      el('div', { className: ['lane'], ariaHidden: 'true' }),
      el('svg', { className: ['arrows'], ariaHidden: 'true' }),
    ]),
  ];
  if (notes.length) {
    children.push(
      el('ol', { className: ['notes-list'] }, notes.map((n, i) => el('li', { dataN: i, dataLine: n.line }, [text(n.text)]))),
    );
  }
  const caption = attrs[kind];
  if (kind !== 'plain' && caption) children.push(el('p', { className: ['why'] }, [text(caption)]));

  return el(
    'figure',
    {
      className: ['panel', `panel-${kind}`],
      dataNotes: notes.length ? JSON.stringify(notes) : undefined,
      dataKind: kind,
    },
    children,
  );
}
