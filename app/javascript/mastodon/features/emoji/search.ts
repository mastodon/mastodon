import { log } from 'debug';
import type { ArrayValues, KeysOfUnion } from 'type-fest';

import {
  loadCustomEmojiKeys,
  loadEmojiByHexcode,
  rawSearch,
  searchCustomEmojisByShortcodes,
} from './database';
import { localeToSegmenter, toSupportedLocale } from './locale';
import { extractTokens } from './normalize';
import type { AnyEmojiData, CustomEmojiData } from './types';

const scoreRanking = [
  'label',
  'shortcode',
  'emoticons',
  'shortcodes',
  'tokens',
] as const satisfies KeysOfUnion<AnyEmojiData>[];
type ScoreRankingKeys = ArrayValues<typeof scoreRanking>;
type ScoreRanking = Record<ScoreRankingKeys, number>;

// Identifier fields hold a match against a complete, canonical string (a
// shortcode, label, emoticon, or legacy shortcode). Token fields only hold
// matches against derived word fragments (e.g. one half of an
// underscore-split shortcode, or a single tag word) — a much weaker
// signal. Identifier matches should always outrank token matches, no
// matter how good the token match's own score is.
const identifierFields = new Set<ScoreRankingKeys>([
  'label',
  'shortcode',
  'emoticons',
  'shortcodes',
]);

interface BestRank {
  categoryWeight: number;
  score: number;
  fieldWeight: number;
}
type ScoredEmoji = AnyEmojiData & { scores: ScoreRanking };
type ScoreMap = Map<string, ScoredEmoji>;

export async function search({
  query,
  locale: localeString,
  limit = 0,
}: {
  query: string;
  locale: string;
  limit?: number;
}) {
  performance.mark('emoji-search-start');

  // Get the locale, and extract tokens from the query.
  const locale = toSupportedLocale(localeString);
  const segmenter = localeToSegmenter(locale);
  const queryTokens = extractTokens(query, segmenter);

  if (queryTokens.length === 0) {
    log('no tokens extracted from query "%s"', query);
    return [];
  }
  const lastToken = queryTokens.at(-1);
  if (!lastToken) {
    throw new Error('Missing tokens from query');
  }

  log('searching for tokens %o in locale %s', queryTokens, locale);

  // Create an array of emoji results
  const resultArrays: ScoreMap[] = [];
  const existingCustomShortcodes = new Set<string>();

  for (let i = 0; i < queryTokens.length; i++) {
    const token = queryTokens[i];
    if (!token) continue;

    // Only query the range for the last token to allow partial matches.
    const { unicodeResults, customResults, shortcodeResults } = await rawSearch(
      token,
      locale,
      i === queryTokens.length - 1,
    );
    const resultMap: ScoreMap = new Map();
    const checkedSet = new Set<string>();

    // Score unicode results.
    for (const emoji of unicodeResults) {
      if (checkedSet.has(emoji.hexcode)) {
        continue;
      }
      checkedSet.add(emoji.hexcode);
      const scores = getScoreForEmoji(emoji, token);
      if (scores) {
        resultMap.set(emoji.hexcode, { ...emoji, scores });
      }
    }

    // Score custom emojis.
    for (const emoji of customResults) {
      if (checkedSet.has(emoji.shortcode)) {
        continue;
      }
      checkedSet.add(emoji.shortcode);
      const scores = getScoreForEmoji(emoji, token);
      if (scores) {
        existingCustomShortcodes.add(emoji.shortcode);
        resultMap.set(emoji.shortcode, { ...emoji, scores });
      }
    }

    // Score based on legacy shortcodes, using the higher score if there's a match.
    for (const shortcodeResult of shortcodeResults) {
      const emoji =
        resultMap.get(shortcodeResult.hexcode) ??
        (await loadEmojiByHexcode(shortcodeResult.hexcode, locale));
      if (!emoji || !('hexcode' in emoji)) {
        continue;
      }

      const newScores = getScoreForEmoji(
        {
          ...emoji,
          shortcodes: shortcodeResult.shortcodes,
        },
        token,
      );
      if (!newScores) {
        continue;
      }
      const oldScores = resultMap.get(emoji.hexcode)?.scores;
      let scores = newScores;
      if (oldScores) {
        scores = Object.fromEntries(
          scoreRanking.map((key) => [
            key,
            newScores[key] !== -1 && oldScores[key] !== -1
              ? Math.min(newScores[key], oldScores[key])
              : Math.max(newScores[key], oldScores[key]),
          ]),
        ) as ScoreRanking;
      }
      resultMap.set(emoji.hexcode, { ...emoji, scores });
    }

    log('found %d results for token "%s"', resultMap.size, token);
    resultArrays.push(resultMap);
  }

  const mixedResults = Array.from(
    resultArrays
      .reduce((prev, curr) => {
        const intersection: ScoreMap = new Map();
        for (const [code, emoji] of prev) {
          if (curr.has(code)) {
            intersection.set(code, emoji);
          }
        }
        return intersection;
      })
      .values(),
  );

  // If there are no results, try a cursor-based custom emoji search instead.
  if (mixedResults.length === 0 || mixedResults.length < limit) {
    const customEmojisFound = await fullCustomSearch(
      query,
      existingCustomShortcodes,
    );
    if (customEmojisFound.length > 0) {
      log(
        'cursor search found %d results for "%s"',
        customEmojisFound.length,
        query,
      );
      mixedResults.push(...customEmojisFound);
    }
  }

  const results: ScoredEmoji[] = [];
  const resultEmojis = new Set<string>();
  for (const result of mixedResults.toSorted(compareRankedEmoji)) {
    const id = 'shortcode' in result ? result.shortcode : result.hexcode;
    if (resultEmojis.has(id)) {
      continue;
    }
    results.push(result);
    resultEmojis.add(id);
    if (limit > 0 && results.length > limit) {
      break;
    }
  }

  const time = performance.measure('emoji-search-end', 'emoji-search-start');
  log(
    'search for "%s" in locale %s returned %d results and took %dms',
    query,
    locale,
    mixedResults.length,
    time.duration,
  );
  if (limit > 0) {
    return results.slice(0, limit);
  }
  return results;
}

function hasField(
  emoji: AnyEmojiData,
  field: string,
): field is keyof typeof emoji {
  return Object.hasOwn(emoji, field);
}

// Creates ranked scores for a given emoji.
function getScoreForEmoji(emoji: AnyEmojiData, query: string) {
  const scores = Object.fromEntries(
    scoreRanking.map((field) => [field, -1]),
  ) as ScoreRanking;
  let hasScore = false;

  for (const field of scoreRanking) {
    if (hasField(emoji, field)) {
      const value = emoji[field] as string | string[] | undefined;
      if (value === undefined) {
        continue;
      }
      const tokens = Array.isArray(value) ? value : [value];
      const score = getScoreForEmojiTokens(tokens, query);

      if (score >= 0) {
        scores[field] = score;
        hasScore = true;
      }
    }
  }

  if (!hasScore) {
    return null;
  }

  return scores;
}

// Compares two scored emojis by getting the best rank.
function compareRankedEmoji(a: ScoredEmoji, b: ScoredEmoji): number {
  const rankA = getBestRank(a.scores);
  const rankB = getBestRank(b.scores);

  // Identifier matches always outrank token matches, regardless of score.
  if (rankA.categoryWeight !== rankB.categoryWeight) {
    return rankA.categoryWeight - rankB.categoryWeight;
  }
  // Within the same category, compare the scores directly.
  if (rankA.score !== rankB.score) {
    return rankA.score - rankB.score;
  }
  // If equal, compare field weights.
  if (rankA.fieldWeight !== rankB.fieldWeight) {
    return rankA.fieldWeight - rankB.fieldWeight;
  }

  // Lastly prioritize Unicode emojis.
  const aIsCustom = hasField(a, 'shortcode');
  const bIsCustom = hasField(b, 'shortcode');
  if (aIsCustom !== bIsCustom) {
    return aIsCustom ? -1 : 1;
  }

  return 0;
}

// Extracts the best rank for a score ranking.
function getBestRank(scores: ScoreRanking): BestRank {
  let best: BestRank | null = null;

  // Use the index to determine field weight.
  for (const [fieldWeight, field] of scoreRanking.entries()) {
    const score = scores[field];
    if (score < 0) {
      continue;
    }
    // Also weight identifier fields over other fields.
    const categoryWeight = identifierFields.has(field) ? 0 : 1;
    if (
      !best ||
      categoryWeight < best.categoryWeight ||
      (categoryWeight === best.categoryWeight &&
        (score < best.score ||
          (score === best.score && fieldWeight < best.fieldWeight)))
    ) {
      best = { categoryWeight, score, fieldWeight };
    }
  }

  return (
    best ?? {
      categoryWeight: 2,
      score: Infinity,
      fieldWeight: scoreRanking.length,
    }
  );
}

function getScoreForEmojiTokens(tokens: string[], query: string) {
  let lowestScore = -1;

  for (const token of tokens) {
    let score = -1;
    // Priority: exact match, prefix match, substring,
    if (token === query) {
      score = 0;
    } else if (token.startsWith(query)) {
      score = 1 + query.length / token.length;
    } else if (token.includes(query)) {
      score = 2 + query.length / token.length;
    } // TODO: Add fuzzy search if needed

    if (score >= 0 && (score < lowestScore || lowestScore < 0)) {
      lowestScore = score;
    }
  }

  return lowestScore;
}

async function fullCustomSearch(query: string, existing = new Set<string>()) {
  const foundEmojis = new Set<string>();

  // First iterate over chunks of 1,000 custom emoji keys and find any matches.
  const chunkSize = 1_000;
  let lastKey: string | null = null;
  let keys: string[] = [];
  do {
    keys = await loadCustomEmojiKeys(lastKey, chunkSize);

    if (keys.length === 0) {
      break;
    }
    log('cursor search got batch of %d emojis', keys.length);
    lastKey = keys.at(-1) ?? null;

    for (const key of keys) {
      if (!foundEmojis.has(key) && !existing.has(key) && key.includes(query)) {
        foundEmojis.add(key);
      }
    }
  } while (keys.length === chunkSize);

  // Next get the full emojis for all matches.
  const emojis = await searchCustomEmojisByShortcodes(Array.from(foundEmojis));
  const results: (CustomEmojiData & { scores: ScoreRanking })[] = [];
  for (const emoji of emojis) {
    const scores = getScoreForEmoji(emoji, query);
    if (scores) {
      results.push({
        scores,
        ...emoji,
      });
    }
  }
  return results;
}
