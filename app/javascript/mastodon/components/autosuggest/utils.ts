import { isRecordObject } from '@/mastodon/utils/objects';
import { stringOrUndefined } from '@/mastodon/utils/strings';

import { WORD } from '../../utils/hashtags';

import type { Source, Suggestion } from './types';

export function textAtCursorMatchesToken(
  str: string,
  caretPosition: number,
  searchTokens: string[],
) {
  let word: string;

  const regex = new RegExp(
    `[${searchTokens.join('')}${WORD}+-]+(\\s[\\p{Script=Latin}\\p{Script=Cyrillic}\\p{M}]+)?$`,
    'iu',
  );
  const left = str.slice(0, caretPosition).search(regex);
  const right = str.slice(caretPosition).search(/\s/);

  if (right < 0) {
    word = str.slice(left);
  } else {
    word = str.slice(left, right + caretPosition);
  }

  word = word.trim();

  if (word.length < 3 || (word[0] && !searchTokens.includes(word[0]))) {
    return [null, null] as const;
  }

  if (word.length > 0) {
    return [left + 1, word] as const;
  } else {
    return [null, null] as const;
  }
}

export function immutableListToSuggestions(list: Immutable.List<unknown>) {
  const suggestions: Suggestion[] = [];
  const hashtagSet = new Set<string>();

  let fakeId = 0;

  for (const suggestion of list.toArray()) {
    if (!isRecordObject(suggestion)) {
      continue;
    }
    const type = suggestion.type;
    const id = stringOrUndefined(suggestion.id) ?? `fake-${fakeId++}`; // Fake ID so we don't have React key issues.

    switch (type) {
      case 'account':
        suggestions.push({
          type,
          id,
        });
        break;
      case 'emoji':
        suggestions.push({
          type,
          id,
          custom: !!suggestion.custom,
          native: stringOrUndefined(suggestion.native),
          imageUrl: stringOrUndefined(suggestion.imageUrl),
        });
        break;
      case 'hashtag': {
        const name = stringOrUndefined(suggestion.name);
        if (!name || hashtagSet.has(name)) {
          continue;
        }

        hashtagSet.add(name);

        suggestions.push({
          type,
          name,
          id,
          totalUses: tagHistoryToUses(suggestion.history),
        });
      }
    }
  }

  return suggestions;
}

export function tagHistoryToUses(history: unknown) {
  if (!Array.isArray(history)) {
    return 0;
  }

  return history.reduce<number>(
    (total, current) =>
      isRecordObject(current) && typeof current.uses === 'number'
        ? total + current.uses
        : total,
    0,
  );
}

export function sourceToElement(source: Source) {
  return !source || source instanceof HTMLElement ? source : source.current;
}
