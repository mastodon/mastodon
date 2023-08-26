import escapeTextContentForBrowser from 'escape-html';

import emojify from '../../features/emoji/emoji';
import { expandSpoilers } from '../../initial_state';
import { unescapeHTML } from '../../utils/html';

const domParser = new DOMParser();

const makeEmojiMap = emojis => emojis.reduce((obj, emoji) => {
  obj[`:${emoji.shortcode}:`] = emoji;
  return obj;
}, {});

export function searchTextFromRawStatus (status) {
  const spoilerText   = status.spoiler_text || '';
  const searchContent = ([spoilerText, status.content].concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])).concat(status.media_attachments.map(att => att.description)).join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');
  return domParser.parseFromString(searchContent, 'text/html').documentElement.textContent;
}

export function normalizeAccount(account) {
  account = { ...account };

  const emojiMap = makeEmojiMap(account.emojis);
  const displayName = account.display_name.trim().length === 0 ? account.username : account.display_name;

  account.display_name_html = emojify(escapeTextContentForBrowser(displayName), emojiMap);
  account.note_emojified = emojify(account.note, emojiMap);
  account.note_plain = unescapeHTML(account.note);

  if (account.fields) {
    account.fields = account.fields.map(pair => ({
      ...pair,
      name_emojified: emojify(escapeTextContentForBrowser(pair.name), emojiMap),
      value_emojified: emojify(pair.value, emojiMap),
      value_plain: unescapeHTML(pair.value),
    }));
  }

  if (account.moved) {
    account.moved = account.moved.id;
  }

  return account;
}

export function normalizeFilterResult(result) {
  const normalResult = { ...result };

  normalResult.filter = normalResult.filter.id;

  return normalResult;
}

export function normalizeStatus(status, normalOldStatus) {
  const normalStatus   = { ...status };
  normalStatus.account = status.account.id;

  if (status.reblog && status.reblog.id) {
    normalStatus.reblog = status.reblog.id;
  }

  if (status.poll && status.poll.id) {
    normalStatus.poll = status.poll.id;
  }

  if (status.filtered) {
    normalStatus.filtered = status.filtered.map(normalizeFilterResult);
  }

  // Only calculate these values when status first encountered and
  // when the underlying values change. Otherwise keep the ones
  // already in the reducer
  if (normalOldStatus && normalOldStatus.get('content') === normalStatus.content && normalOldStatus.get('spoiler_text') === normalStatus.spoiler_text) {
    normalStatus.search_index = normalOldStatus.get('search_index');
    normalStatus.contentHtml = normalOldStatus.get('contentHtml');
    normalStatus.spoilerHtml = normalOldStatus.get('spoilerHtml');
    normalStatus.spoiler_text = normalOldStatus.get('spoiler_text');
    normalStatus.hidden = normalOldStatus.get('hidden');

    if (normalOldStatus.get('translation')) {
      normalStatus.translation = normalOldStatus.get('translation');
    }
  } else {
    // If the status has a CW but no contents, treat the CW as if it were the
    // status' contents, to avoid having a CW toggle with seemingly no effect.
    if (normalStatus.spoiler_text && !normalStatus.content) {
      normalStatus.content = normalStatus.spoiler_text;
      normalStatus.spoiler_text = '';
    }

    const spoilerText   = normalStatus.spoiler_text || '';
    const searchContent = ([spoilerText, status.content].concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])).concat(status.media_attachments.map(att => att.description)).join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');
    const emojiMap      = makeEmojiMap(normalStatus.emojis);

    normalStatus.search_index = domParser.parseFromString(searchContent, 'text/html').documentElement.textContent;
    normalStatus.contentHtml  = emojify(normalStatus.content, emojiMap);
    normalStatus.spoilerHtml  = emojify(escapeTextContentForBrowser(spoilerText), emojiMap);
    normalStatus.hidden       = expandSpoilers ? false : spoilerText.length > 0 || normalStatus.sensitive;
  }

  if (normalOldStatus) {
    const list = normalOldStatus.get('media_attachments');
    if (normalStatus.media_attachments && list) {
      normalStatus.media_attachments.forEach(item => {
        const oldItem = list.find(i => i.get('id') === item.id);
        if (oldItem && oldItem.get('description') === item.description) {
          item.translation = oldItem.get('translation')
        }
      });
    }
  }

  return normalStatus;
}

export function normalizeStatusTranslation(translation, status) {
  const emojiMap = makeEmojiMap(status.get('emojis').toJS());

  const normalTranslation = {
    detected_source_language: translation.detected_source_language,
    language: translation.language,
    provider: translation.provider,
    contentHtml: emojify(translation.content, emojiMap),
    spoilerHtml: emojify(escapeTextContentForBrowser(translation.spoiler_text), emojiMap),
    spoiler_text: translation.spoiler_text,
  };

  return normalTranslation;
}

export function normalizePoll(poll, normalOldPoll) {
  const normalPoll = { ...poll };
  const emojiMap = makeEmojiMap(poll.emojis);

  normalPoll.options = poll.options.map((option, index) => {
    const normalOption = {
      ...option,
      voted: poll.own_votes && poll.own_votes.includes(index),
      titleHtml: emojify(escapeTextContentForBrowser(option.title), emojiMap),
    }

    if (normalOldPoll && normalOldPoll.getIn(['options', index, 'title']) === option.title) {
      normalOption.translation = normalOldPoll.getIn(['options', index, 'translation']);
    }

    return normalOption
  });

  return normalPoll;
}

export function normalizePollOptionTranslation(translation, poll) {
  const emojiMap = makeEmojiMap(poll.get('emojis').toJS());

  const normalTranslation = {
    ...translation,
    titleHtml: emojify(escapeTextContentForBrowser(translation.title), emojiMap),
  };

  return normalTranslation;
}

export function normalizeAnnouncement(announcement) {
  const normalAnnouncement = { ...announcement };
  const emojiMap = makeEmojiMap(normalAnnouncement.emojis);

  normalAnnouncement.contentHtml = emojify(normalAnnouncement.content, emojiMap);

  return normalAnnouncement;
}
