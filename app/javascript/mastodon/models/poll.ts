import type { RecordOf } from 'immutable';
import { Record, List } from 'immutable';

import escapeTextContentForBrowser from 'escape-html';

import type { ApiPollJSON, ApiPollOptionJSON } from 'mastodon/api_types/polls';
import emojify from 'mastodon/features/emoji/emoji';

import { CustomEmojiFactory, makeEmojiMap } from './custom_emoji';
import type { CustomEmoji, EmojiMap } from './custom_emoji';

interface PollOptionTranslationShape {
  title: string;
  titleHtml: string;
}

export type PollOptionTranslation = RecordOf<PollOptionTranslationShape>;

export const PollOptionTranslationFactory = Record<PollOptionTranslationShape>({
  title: '',
  titleHtml: '',
});

interface PollOptionShape extends Required<ApiPollOptionJSON> {
  voted: boolean;
  titleHtml: string;
  translation: PollOptionTranslation | null;
}

export function createPollOptionTranslationFromServerJSON(
  translation: { title: string },
  emojiMap: EmojiMap,
) {
  return PollOptionTranslationFactory({
    ...translation,
    titleHtml: emojify(
      escapeTextContentForBrowser(translation.title),
      emojiMap,
    ),
  });
}

export type PollOption = RecordOf<PollOptionShape>;

export const PollOptionFactory = Record<PollOptionShape>({
  title: '',
  votes_count: 0,
  voted: false,
  titleHtml: '',
  translation: null,
});

interface PollShape
  extends Omit<ApiPollJSON, 'emojis' | 'options' | 'own_votes'> {
  emojis: List<CustomEmoji>;
  options: List<PollOption>;
  own_votes?: List<number>;
}
export type Poll = RecordOf<PollShape>;

export const PollFactory = Record<PollShape>({
  id: '',
  expires_at: '',
  expired: false,
  multiple: false,
  voters_count: 0,
  votes_count: 0,
  voted: false,
  emojis: List<CustomEmoji>(),
  options: List<PollOption>(),
  own_votes: List(),
});

export function createPollFromServerJSON(
  serverJSON: ApiPollJSON,
  previousPoll?: Poll,
) {
  const emojiMap = makeEmojiMap(serverJSON.emojis);

  return PollFactory({
    ...serverJSON,
    emojis: List(serverJSON.emojis.map((emoji) => CustomEmojiFactory(emoji))),
    own_votes: serverJSON.own_votes ? List(serverJSON.own_votes) : undefined,
    options: List(
      serverJSON.options.map((optionJSON, index) => {
        const option = PollOptionFactory({
          ...optionJSON,
          voted: serverJSON.own_votes?.includes(index) || false,
          titleHtml: emojify(
            escapeTextContentForBrowser(optionJSON.title),
            emojiMap,
          ),
        });

        const prevOption = previousPoll?.options.get(index);
        if (prevOption?.translation && prevOption.title === option.title) {
          const { translation } = prevOption;

          option.set(
            'translation',
            createPollOptionTranslationFromServerJSON(translation, emojiMap),
          );
        }

        return option;
      }),
    ),
  });
}
