import rss from '@astrojs/rss';
import type { APIContext } from 'astro';

import { site, tips, tipUrl } from '../lib/site';

export function GET(context: APIContext) {
  return rss({
    title: site.name,
    description: 'Flutter tips that still compile.',
    site: context.site!,
    items: tips.map((t) => ({
      title: t.title,
      description: t.summary,
      link: tipUrl(t.slug),
      pubDate: new Date(`${t.published}T00:00:00Z`),
      categories: t.tags,
    })),
  });
}
