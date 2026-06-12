import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import type { Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { toSupportedLocale } from '@/mastodon/features/emoji/locale';
import type { ExtraCustomEmojiMap } from '@/mastodon/features/emoji/types';
import { createAsyncThunk } from '@/mastodon/store/typed_functions';

interface EmojisState {
  custom: Record<string, Pick<ApiCustomEmojiJSON, 'url' | 'static_url'>>;
  customCategories: Record<string, string[]>; // { name: shortcodes[] }
  localesLoaded: Locale[];
}

const emojisSlice = createSlice({
  name: 'emojis',
  initialState: {
    custom: {},
    customCategories: {},
    localesLoaded: [],
  } as EmojisState,
  reducers: {
    loadLocale(state, action: PayloadAction<string>) {
      const locale = toSupportedLocale(action.payload);
      if (!state.localesLoaded.includes(locale)) {
        state.localesLoaded.push(locale);
      }
    },
  },
  extraReducers(builder) {
    builder.addAsyncThunk(loadCustomEmojis, {
      fulfilled(state, action) {
        if (!action.payload?.length) {
          return;
        }

        for (const emoji of action.payload) {
          const { shortcode, category, url, static_url } = emoji;
          state.custom[shortcode] = {
            url,
            static_url,
          };

          if (category) {
            state.customCategories[category] ??= [];
            if (!state.customCategories[category].includes(shortcode)) {
              state.customCategories[category].push(shortcode);
            }
          }
        }
      },
    });
  },
  selectors: {
    selectCustomEmojis(state): ExtraCustomEmojiMap {
      const emojis: ExtraCustomEmojiMap = {};
      for (const shortcode in state.custom) {
        const emoji = state.custom[shortcode];
        if (!emoji) {
          continue;
        }
        emojis[shortcode] = {
          shortcode,
          ...emoji,
        };
      }
      return emojis;
    },
  },
});

export const emojis = emojisSlice.reducer;
export const { loadLocale } = emojisSlice.actions;
export const { selectCustomEmojis } = emojisSlice.selectors;

export const loadCustomEmojis = createAsyncThunk(
  `${emojisSlice.name}/loadCustomEmojis`,
  async () => {
    const { loadAllCustomEmoji } =
      await import('@/mastodon/features/emoji/database');
    return loadAllCustomEmoji();
  },
);
