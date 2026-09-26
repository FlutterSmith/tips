// @ts-check
import { unified } from '@astrojs/markdown-remark';
import { defineConfig } from 'astro/config';

import { rehypePanels, remarkTips } from './src/lib/markdown.mjs';

const base = process.env.SITE_BASE ?? '/tips';

export default defineConfig({
  site: process.env.SITE_URL ?? 'https://fluttersmith.github.io',
  base,
  trailingSlash: 'always',
  markdown: {
    // Code blocks are highlighted by rehypePanels, which also draws the
    // annotated code panels. Astro's own highlighter stays out of the way.
    syntaxHighlight: false,
    processor: unified({
      remarkPlugins: [[remarkTips, { base }]],
      rehypePlugins: [rehypePanels],
    }),
  },
  build: { format: 'directory' },
  devToolbar: { enabled: false },
});
