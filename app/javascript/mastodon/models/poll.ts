import escapeTextContentForBrowser from 'escape-html';

import type { ApiPollJSON, ApiPollOptionJSON } from 'mastodon/api_types/polls';

import { CustomEmojiFactory } from './custom_emoji';
import type { CustomEmoji } from './custom_emoji';

interface PollOptionTranslation {
  title: string;
  titleHtml: string;
}

export interface PollOption extends ApiPollOptionJSON {
  voted: boolean;
  titleHtml: string;
  translation: PollOptionTranslation | null;
}

export function createPollOptionTranslationFromServerJSON(translation: {
  title: string;
}) {
  return {
    ...translation,
    titleHtml: escapeTextContentForBrowser(translation.title),
  } as PollOptionTranslation;
}

export interface Poll extends Omit<
  ApiPollJSON,
  'emojis' | 'options' | 'own_votes'
> {
  emojis: CustomEmoji[];
  options: PollOption[];
  own_votes?: number[];
}

const pollDefaultValues = {
  expired: false,
  multiple: false,
  voters_count: 0,
  votes_count: 0,
  voted: false,
  own_votes: [],
};

export function createPollFromServerJSON(
  serverJSON: ApiPollJSON,
  previousPoll?: Poll,
) {
  return {
    ...pollDefaultValues,
    ...serverJSON,
    emojis: serverJSON.emojis.map((emoji) => CustomEmojiFactory(emoji)),
    options: serverJSON.options.map((optionJSON, index) => {
      const option = {
        ...optionJSON,
        voted: serverJSON.own_votes?.includes(index) || false,
        titleHtml: escapeTextContentForBrowser(optionJSON.title),
      } as PollOption;

      const prevOption = previousPoll?.options[index];
      if (prevOption?.translation && prevOption.title === option.title) {
        const { translation } = prevOption;

        option.translation =
          createPollOptionTranslationFromServerJSON(translation);
      }

      return option;
    }),
  } as Poll;
}
