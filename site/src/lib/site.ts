import meta from '../generated/meta.json';

export type Level = 'beginner' | 'intermediate' | 'advanced';
export type Status = 'current' | 'outdated' | 'archived';

export interface TipMeta {
  slug: string;
  number: number;
  title: string;
  summary: string;
  category: string;
  tags: string[];
  level: Level;
  published: string;
  status: Status;
  experimental: boolean;
  packages: Record<string, string>;
  related: string[];
  readingMinutes: number;
  origin: null | { upstreamId: number; url: string; change: string; credit: string };
  previous: string | null;
  next: string | null;
}

export interface Category {
  id: string;
  label: string;
  count: number;
}

export interface LearningPath {
  id: string;
  title: string;
  summary: string;
  tips: string[];
}

export const site = {
  name: 'fluttersmith/tips',
  repo: 'https://github.com/FlutterSmith/tips',
  flutter: meta.flutter as string,
  dart: meta.dart as string,
  verifiedAt: meta.verifiedAt as string,
};

const all = meta.tips as TipMeta[];

/** Published, non-archived tips, newest (highest number) first. */
export const tips: TipMeta[] = all.filter((t) => t.status !== 'archived').sort((a, b) => b.number - a.number);
export const categories: Category[] = (meta.categories as Category[]).filter((c) => c.count > 0);
export const tags = meta.tags as Record<string, string>;
export const paths = meta.paths as LearningPath[];
export const upstream = meta.upstream as Record<string, string>;

const bySlug = new Map(all.map((t) => [t.slug, t]));
export const tip = (slug: string) => bySlug.get(slug);
export const categoryLabel = (id: string) => (meta.categories as Category[]).find((c) => c.id === id)?.label ?? id;

export const pad = (n: number) => String(n).padStart(3, '0');
export const levelRank: Record<Level, number> = { beginner: 1, intermediate: 2, advanced: 3 };

/** Joins a path onto the configured base, keeping the trailing slash style. */
export function url(path = ''): string {
  const base = import.meta.env.BASE_URL.replace(/\/?$/, '/');
  return base + path.replace(/^\//, '');
}

export const tipUrl = (slug: string) => url(`tips/${slug}/`);

export function formatDate(iso: string): string {
  if (!iso) return '';
  return new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    timeZone: 'UTC',
  });
}

/**
 * The first annotated Dart snippet in a tip's Markdown, for the home page.
 * Returns null when the tip has no annotated plain snippet short enough to
 * sit next to its notes without scrolling.
 */
export function firstAnnotatedSnippet(body: string, maxWidth = 44): { code: string; meta: string } | null {
  const re = /<\?code-excerpt\s+"([^"]+)"[^\n]*\n```dart([^\n]*)\n([\s\S]*?)\n```/g;
  for (const m of body.matchAll(re)) {
    const [, file, info, code] = m;
    if (/\b(do|dont)="/.test(info) || !code.includes('@note')) continue;
    const lines = code.split('\n').filter((l) => !l.includes('@note'));
    // A hero snippet needs a few lines to show off, but not a scrollbar.
    if (lines.length < 4 || Math.max(...lines.map((l) => l.length)) > maxWidth) continue;
    return { code, meta: `${info.trim()} file="${file.split('/').pop()}"`.trim() };
  }
  return null;
}
