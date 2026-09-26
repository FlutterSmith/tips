import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

// The Dart CLI (`tips validate`) is the real gatekeeper for frontmatter.
// This schema only types the fields the pages read.
const tips = defineCollection({
  loader: glob({
    pattern: '*/index.md',
    base: '../content/tips',
    generateId: ({ entry }) => entry.split('/')[0],
  }),
  schema: z.looseObject({
    slug: z.string(),
    title: z.string(),
    summary: z.string(),
  }),
});

export const collections = { tips };
