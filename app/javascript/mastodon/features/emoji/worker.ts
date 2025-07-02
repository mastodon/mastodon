/* eslint-disable no-console -- REMOVE BEFORE MERGE!! */
import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';

import {
  loadLatestEtag,
  putCustomEmojiData,
  putEmojiData,
  putLatestEtag,
} from './database';
import {
  loadLocaleEmojis,
  toSupportedLocale,
  toSupportedLocaleOrCustom,
} from './locale';

addEventListener('message', handleMessage);

function handleMessage(event: MessageEvent<string>) {
  const { data: target } = event;
  if (target !== 'custom') {
    void importEmojiData(target);
  } else {
    void importCustomEmojiData();
  }
}

async function importEmojiData(localeString: string) {
  const locale = toSupportedLocale(localeString);
  console.log('emoji worker:', `loading data for ${locale}`);
  const emojis = await loadLocaleEmojis(locale);
  await putEmojiData(emojis, locale);
  console.log('emoji worker:', `inserted ${emojis.length} for ${locale}`);
}

async function importCustomEmojiData() {
  console.log('emoji worker:', 'loading custom emojis');
  const emojis = await fetchAndCheckEtag<ApiCustomEmojiJSON[]>('custom');
  if (!emojis) {
    return;
  }
  await putCustomEmojiData(emojis);
  console.log('emoji worker:', `inserted ${emojis.length} custom emojis`);
}

async function fetchAndCheckEtag<ResultType extends object[]>(
  localeOrCustom: string,
): Promise<ResultType | null> {
  const locale = toSupportedLocaleOrCustom(localeOrCustom);
  const oldEtag = await loadLatestEtag(locale);
  let uri = `/emoji/${locale}`; // Placeholder while I figure out Vite
  if (localeOrCustom === 'custom') {
    uri = '/api/v1/custom_emojis';
  }
  const response = await fetch(uri, {
    headers: {
      'Content-Type': 'application/json',
      'If-None-Match': oldEtag ?? '',
    },
  });
  if (response.status === 304) {
    console.log('emoji worker:', `no changes for ${localeOrCustom}`);
    return null;
  }
  if (!response.ok) {
    throw new Error(
      `Failed to fetch emoji data for ${localeOrCustom}: ${response.statusText}`,
    );
  }
  const etag = response.headers.get('ETag');
  if (etag) {
    await putLatestEtag(etag, localeOrCustom);
    console.log('emoji worker:', `updated etag for ${localeOrCustom}: ${etag}`);
  }
  const data = (await response.json()) as ResultType;
  if (!Array.isArray(data)) {
    throw new Error(
      `Unexpected data format for ${localeOrCustom}: expected an array`,
    );
  }

  return data;
}
