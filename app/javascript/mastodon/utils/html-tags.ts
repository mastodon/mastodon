import type { ReactHTML } from 'react';

export interface AllowedTag {
  /* True means allow, false disallows global attributes, string renames the attribute name for React. */
  attributes?: Record<string, boolean | string>;
  /* If false, the tag cannot have children. Undefined or true means allowed. */
  children?: boolean;
}

export type AllowedTagsType = {
  [Tag in keyof ReactHTML]?: AllowedTag;
};

export const GlobalAttributes: Record<string, boolean | string> = {
  class: 'className',
  id: true,
  title: true,
  dir: true,
  lang: true,
};

export const AllowedTags: AllowedTagsType = {
  p: {},
  br: { children: false },
  span: { attributes: { translate: true } },
  a: { attributes: { href: true, rel: true, translate: true, target: true } },
  del: {},
  s: {},
  pre: {},
  blockquote: {},
  code: {},
  b: {},
  strong: {},
  u: {},
  i: {},
  // For inline emojis.
  img: { children: false, attributes: { src: true, alt: true, title: true } },
  em: {},
  ul: {},
  ol: { attributes: { start: true, reversed: true } },
  li: { attributes: { value: true } },
  ruby: {},
  rt: {},
  rp: {},
};
