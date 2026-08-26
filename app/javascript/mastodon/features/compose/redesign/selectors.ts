import { length } from 'stringz';

import type { ApiMediaAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import { immutableListToSuggestions } from '@/mastodon/components/autosuggest/utils';
import type { StatusVisibility } from '@/mastodon/models/status';
import type { ComposeType } from '@/mastodon/reducers/slices/composer';
import { createAppSelector } from '@/mastodon/store';
import { DAY, MINUTE } from '@/mastodon/utils/time';

import { countableText } from '../util/counter';

export const selectComposePrivacy = createAppSelector(
  [
    (state) => state.compose.get('privacy') as StatusVisibility | null,
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  ],
  (privacy, defaultPrivacy) => privacy ?? defaultPrivacy,
);

export const selectComposeType = createAppSelector(
  [
    (state) => state.compose.get('in_reply_to') as string | null,
    selectComposePrivacy,
  ],
  (inReplyToId, privacy) => {
    let type: ComposeType = 'post';
    if (inReplyToId) {
      type = 'reply';
    } else if (privacy === 'direct') {
      type = 'message';
    }

    return type;
  },
);

export const selectComposeCharsCount = createAppSelector(
  [
    (state) => state.server.server.item?.configuration.statuses.max_characters,
    (state) => state.compose.get('text') as string,
    (state) =>
      state.compose.get('spoiler')
        ? (state.compose.get('spoiler_text') as string)
        : '',
  ],
  (maxChars, text, spoilerText) => {
    const allText = (countableText(text) as string) + spoilerText;
    return {
      text,
      allText,
      max: maxChars ?? 500,
      current: length(allText),
    };
  },
);

export const selectComposeCanSubmit = createAppSelector(
  [
    (state) => !!state.compose.get('is_submitting'),
    (state) => !!state.compose.get('is_uploading'),
    (state) => !!state.compose.get('is_changing_upload'),
    selectComposeCharsCount,
  ],
  (isSubmitting, isUploading, isChangingUpload, { text, max }) =>
    !isSubmitting &&
    !isUploading &&
    !isChangingUpload &&
    text.trim().length <= max &&
    text.trim().length > 0,
);

export const selectComposeMentions = createAppSelector(
  [
    (state) => state.accounts_map,
    (state) => state.compose.get('text') as string,
    (state) => state.server.server.item?.domain,
  ],
  (accountsMap, text, localDomain) => {
    const accounts = new Set<string>();
    const potentialAccounts = text.matchAll(
      /@(?<username>[a-zA-Z0-9_.-]+)(?<domain>@[a-zA-Z0-9_.-]+)?/g,
    );
    for (const match of potentialAccounts) {
      const { username, domain } = match.groups ?? {};
      if (!username) {
        continue;
      }
      const account =
        domain && domain !== localDomain ? `${username}@${domain}` : username;
      if (accountsMap[account]) {
        accounts.add(accountsMap[account]);
      }
    }
    return [...accounts];
  },
);

export const selectComposeSensitive = createAppSelector(
  [
    (state) => !!state.compose.get('spoiler'),
    (state) => state.compose.get('spoiler_text'),
  ],
  (sensitive, text) => ({
    sensitive,
    sensitiveText: typeof text === 'string' ? text : '',
  }),
);

export const PER_LINE = 8;
export const LINES = 2;
const DEFAULTS = [
  '+1',
  'grinning',
  'kissing_heart',
  'heart_eyes',
  'laughing',
  'stuck_out_tongue_winking_eye',
  'sweat_smile',
  'joy',
  'yum',
  'disappointed',
  'thinking_face',
  'weary',
  'sob',
  'sunglasses',
  'heart',
  'ok_hand',
];

export const selectFrequentlyUsedEmoji = createAppSelector(
  [
    (state) =>
      state.settings.get('frequentlyUsedEmojis') as
        | Immutable.Map<string, number>
        | undefined,
  ],
  (emojiCounters) => {
    if (!emojiCounters) {
      return DEFAULTS;
    }
    let emojis = emojiCounters
      .toArray()
      .sort((a, b) => a[1] - b[1])
      .reverse()
      .slice(0, PER_LINE * LINES)
      .map(([emoji]) => emoji);

    if (emojis.length < DEFAULTS.length) {
      const uniqueDefaults = DEFAULTS.filter(
        (emoji) => !emojis.includes(emoji),
      );
      emojis = emojis.concat(
        uniqueDefaults.slice(0, DEFAULTS.length - emojis.length),
      );
    }

    return emojis;
  },
);

export const selectComposeHasAttachments = createAppSelector(
  [
    (state) => !!state.compose.get('poll'),
    (state) => state.compose.get('quoted_status_id') as string | null,
    (state) =>
      state.compose.get('media_attachments') as
        | Immutable.List<unknown>
        | undefined,
    (state) => Number(state.compose.get('pending_media_attachments')),
  ],
  (hasPoll, quotedStatusId, attachments, pendingAttachments) => {
    return {
      hasPoll,
      hasAttachments:
        (attachments && attachments.size > 0) || pendingAttachments > 0,
      quotedStatusId,
    };
  },
);

export type ComposeAttachment<
  TAttachment extends ApiMediaAttachmentJSON = ApiMediaAttachmentJSON,
> = TAttachment & {
  file?: File;
  unattached: boolean;
};

export const selectComposeAttachments = createAppSelector(
  [
    (state) =>
      state.compose.get('media_attachments') as
        | Immutable.List<ComposeAttachment>
        | undefined,
  ],
  (attachments) => {
    if (!attachments) {
      return [];
    }
    return attachments.toJS() as ComposeAttachment[];
  },
);

export const selectComposeAttachment = createAppSelector(
  [selectComposeAttachments, (_, id?: string) => id],
  (attachments, id) => {
    if (!id) {
      return null;
    }
    return attachments.find((attachment) => attachment.id === id) ?? null;
  },
);

export const selectComposePoll = createAppSelector(
  [
    (state) =>
      state.compose.get('poll') as Immutable.Map<string, unknown> | null,
    (state) => state.server.server.item?.configuration.polls,
  ],
  (rawPoll, rawConfig) => {
    const config = {
      maxOptions: rawConfig?.max_options ?? 4,
      maxCharacters: rawConfig?.max_characters_per_option ?? 50,
      minExpiration: rawConfig?.min_expiration ?? 5 * MINUTE,
      maxExpiration: rawConfig?.max_expiration ?? 30 * DAY,
    };
    if (rawPoll === null) {
      return {
        options: [],
        expiresIn: DAY,
        multiple: false,
        ...config,
      };
    }

    return {
      options: (rawPoll.get('options') as Immutable.List<string>).toArray(),
      expiresIn: Number(rawPoll.get('expires_in')),
      multiple: !!rawPoll.get('multiple'),
      ...config,
    };
  },
);

export const selectSuggestions = createAppSelector(
  [
    (state) =>
      state.compose.get('suggestions') as unknown as Immutable.List<unknown>,
  ],
  (list) => immutableListToSuggestions(list),
);
