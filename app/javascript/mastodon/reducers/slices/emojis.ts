import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import type { Locale } from 'emojibase';

import type { ApiCustomEmojiJSON } from '@/mastodon/api_types/custom_emoji';
import { toSupportedLocale } from '@/mastodon/features/emoji/locale';
import { createAsyncThunk } from '@/mastodon/store/typed_functions';

interface EmojisState {
  custom: Record<string, Pick<ApiCustomEmojiJSON, 'url' | 'static_url'>>;
  customCategories: Record<string, string[]>; // { name: shortcodes[] }
  customLoaded: boolean;
  localesLoaded: Locale[];
}

const emojisSlice = createSlice({
  name: 'emojis',
  initialState: {
    custom: {},
    customCategories: {},
    customLoaded: false,
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

          state.customLoaded = true;
        }
      },
    });
  },
});

export const emojis = emojisSlice.reducer;
export const { loadLocale } = emojisSlice.actions;

export const loadCustomEmojis = createAsyncThunk(
  `${emojisSlice.name}/loadCustomEmojis`,
  async () => {
    const { loadAllCustomEmoji } =
      await import('@/mastodon/features/emoji/database');
    return loadAllCustomEmoji();
  },
);
