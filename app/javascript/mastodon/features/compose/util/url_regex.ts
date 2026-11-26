import { Extractor, extractUrlsWithIndices } from '@agulbra/uts58';

import { HASHTAG_REGEX } from '@/mastodon/utils/hashtags';

const extractor = new Extractor();

// Replaces every URL uts58 finds in `text` with `replacement`. Walks
// the entities back-to-front so earlier indices stay valid.
export function replaceUrls(text: string, replacement = '') {
  const entities = extractUrlsWithIndices(text, {
    extractUrlsWithoutProtocol: false,
  });
  let out = text;

  // TODO: when the UTS58 gem supports not extracting schemaless URLs
  // const onlyUrlsWithSchema can be removed again
  for (let i = entities.length - 1; i >= 0; i--) {
    const entity = entities[i];
    if (entity) {
      const [start, end] = entity.indices;
      out = out.slice(0, start) + replacement + out.slice(end);
    }
  }
  return out;
}

// Finds @user@host mentions. The host part is intentionally loose —
// anything that isn't whitespace or an obvious delimiter — and then
// vetted by uts58's IDN-aware public-suffix check, so non-ASCII hosts
// like grå.org or 慕田峪长城.网址 pass while bare words ("@arnt@nope")
// don't. The leading group forbids slash (already inside a URL path) and any
// letter/digit/underscore (already inside a word); it's a capture group
// rather than a lookbehind, which Safari < 16.4 can't parse. Username stays
// ASCII to mirror the canonical Account::USERNAME_RE.
const MENTION_RE =
  /(^|[^/\p{L}\p{N}_])@([a-z0-9_]+(?:[a-z0-9_.-]*[a-z0-9_])?)@([^\s@/<>?#]+)/giu;

const TRAILING_HOST_PUNCT = /[.,;:!?)\]}'"`]+$/;

interface MentionIndex {
  indices: [number, number];
  username: string;
  host: string;
}

export function extractMentionsWithIndices(text: string) {
  const out: MentionIndex[] = [];
  for (const match of text.matchAll(MENTION_RE)) {
    const [, prepend = '', username] = match;
    let host = match[3];
    if (!host || !username) {
      continue;
    }

    const trail = TRAILING_HOST_PUNCT.exec(host);
    if (trail) {
      host = host.slice(0, -trail[0].length);
    }

    if (!host || !extractor.isPlausibleHost(host)) {
      continue;
    }

    const start = match.index + prepend.length;
    const end = start + 2 + username.length + host.length;
    out.push({ indices: [start, end], username, host });
  }
  return out;
}

export function replaceMentions(
  text: string,
  replacement: ((mention: MentionIndex) => string) | string = '',
) {
  const mentions = extractMentionsWithIndices(text);
  let out = text;
  for (let i = mentions.length - 1; i >= 0; i--) {
    const mention = mentions[i];
    if (!mention) {
      continue;
    }
    out =
      out.slice(0, mention.indices[0]) +
      (typeof replacement === 'string' ? replacement : replacement(mention)) +
      out.slice(mention.indices[1]);
  }
  return out;
}

export function removeHashtags(text: string) {
  return text.replaceAll(HASHTAG_REGEX, '');
}
