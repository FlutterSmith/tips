// Remark/rehype plugins that turn a tip's GitHub-friendly Markdown into the
// site's markup.
import path from 'node:path';

import { visit } from 'unist-util-visit';

import { buildPanel } from './panel.mjs';

const REPO_BLOB = 'https://github.com/FlutterSmith/tips/blob/main';
const EXCERPT = /^<\?code-excerpt\s+"([^"]+)"/;

/**
 * - drops the generated nav block and HTML comments (the site has its own nav)
 * - moves excerpt markers onto the following fence as `file="…"`
 * - rewrites links between tips to site routes, other relative links to GitHub
 * @param {{ base: string }} options
 */
export function remarkTips({ base }) {
  const root = base.endsWith('/') ? base : `${base}/`;
  return (tree, file) => {
    const children = tree.children;
    const start = children.findIndex((n) => n.type === 'html' && n.value.includes('<!-- tips:nav -->'));
    if (start !== -1) {
      const end = children.findIndex((n, i) => i > start && n.type === 'html' && n.value.includes('<!-- /tips:nav -->'));
      children.splice(start, (end === -1 ? children.length : end + 1) - start);
    }

    for (let i = children.length - 1; i >= 0; i--) {
      const node = children[i];
      if (node.type !== 'html') continue;
      const excerpt = node.value.match(EXCERPT);
      const next = children[i + 1];
      if (excerpt && next?.type === 'code') {
        next.meta = `${next.meta ?? ''} file="${path.posix.basename(excerpt[1])}"`.trim();
      }
      if (excerpt || node.value.trimStart().startsWith('<!--')) children.splice(i, 1);
    }

    const slug = path.basename(path.dirname(file.path ?? file.history?.[0] ?? ''));
    visit(tree, ['link', 'definition'], (node) => {
      const url = node.url;
      if (!url || /^[a-z]+:/i.test(url) || url.startsWith('#')) return;
      const tip = url.match(/^\.\.\/([a-z0-9-]+)\/(?:index\.md)?(#.*)?$/);
      if (tip) {
        node.url = `${root}tips/${tip[1]}/${tip[2] ?? ''}`;
        return;
      }
      node.url = `${REPO_BLOB}/${path.posix.normalize(`content/tips/${slug}/${url}`)}`;
    });
  };
}

/**
 * Replaces every `pre > code` with an annotated code panel, then pairs
 * consecutive Don't/Do panels side by side.
 */
export function rehypePanels() {
  return async (tree) => {
    const jobs = [];
    visit(tree, 'element', (node, index, parent) => {
      if (node.tagName !== 'pre' || !parent) return;
      const code = node.children.find((c) => c.type === 'element' && c.tagName === 'code');
      if (!code) return;
      const lang = (code.properties?.className ?? []).find((c) => String(c).startsWith('language-'))?.slice(9);
      const source = code.children.map((c) => (c.type === 'text' ? c.value : '')).join('');
      jobs.push(
        buildPanel({ code: source, lang, meta: code.data?.meta ?? '' }).then((panel) => {
          parent.children[index] = panel;
        }),
      );
      return 'skip';
    });
    await Promise.all(jobs);
    pairDoDont(tree);
  };
}

function isPanel(node, kind) {
  return node?.type === 'element' && node.properties?.dataKind === kind;
}

function pairDoDont(node) {
  const kids = node.children;
  if (!kids) return;
  for (let i = 0; i < kids.length; i++) {
    if (isPanel(kids[i], 'dont')) {
      let j = i + 1;
      while (kids[j]?.type === 'text' && !kids[j].value.trim()) j++;
      if (isPanel(kids[j], 'do')) {
        const pair = { type: 'element', tagName: 'div', properties: { className: ['dd'] }, children: [kids[i], kids[j]] };
        kids.splice(i, j - i + 1, pair);
        continue;
      }
    }
    // Panels never contain other panels, so there is nothing to pair inside.
    if (!kids[i].properties?.dataKind) pairDoDont(kids[i]);
  }
}
