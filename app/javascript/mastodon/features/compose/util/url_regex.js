import { Extractor, extractUrlsWithIndices } from '@agulbra/uts58';

const extractor = new Extractor();

// Replaces every URL uts58 finds in `text` with `replacement`. Walks
// the entities back-to-front so earlier indices stay valid.
export function replaceUrls(text, replacement) {
  const entities = extractUrlsWithIndices(text);
  let out = text;
  for (let i = entities.length - 1; i >= 0; i--) {
    const [start, end] = entities[i].indices;
    out = out.slice(0, start) + replacement + out.slice(end);
  }
  return out;
}

// Finds @user@host mentions. The host part is intentionally loose —
// anything that isn't whitespace or an obvious delimiter — and then
// vetted by uts58's IDN-aware public-suffix check, so non-ASCII hosts
// like grå.org or 慕田峪长城.网址 pass while bare words ("@arnt@nope")
// don't. Lookbehind forbids slash (already inside a URL path) and any
// letter/digit/underscore (already inside a word). Username stays
// ASCII to mirror the canonical Account::USERNAME_RE.
// equivalent to [[:word:]] we use \p{L}\p{N}\p{M} (letters, numbers, marks)
// and whitelist the tibetan tsek character (\u0F0B)

const MENTION_RE = /(?<![/\p{L}\p{N}_])@([a-z0-9_]+(?:[a-z0-9_.-]*[a-z0-9_])?)@((?:[\p{L}\p{N}\p{M}_\u0F0B]+)?(?:[.-][\p{L}\p{N}\p{M}\u0F0B]+)*)?/giu
const MAX_DOMAIN_LENGTH = 253
const TRAILING_HOST_PUNCT = /[.,;:!?)\]}'"`]+$/;

export function extractMentionsWithIndices(text) {
  const out = [];
  for (const m of text.matchAll(MENTION_RE)) {
    let host = m[2];
    const trail = TRAILING_HOST_PUNCT.exec(host);
    if (trail) host = host.slice(0, -trail[0].length);
    if (!host) continue;
    const start = m.index;
    const end = start + 2 + m[1].length + host.length;
    if ((end-start) > MAX_DOMAIN_LENGTH) continue;
    out.push({ indices: [start, end], username: m[1], host });
  }
  return out;
}

export function replaceMentions(text, replacementFn) {
  const mentions = extractMentionsWithIndices(text);
  let out = text;
  for (let i = mentions.length - 1; i >= 0; i--) {
    const m = mentions[i];
    out = out.slice(0, m.indices[0]) + replacementFn(m) + out.slice(m.indices[1]);
  }
  return out;
}
