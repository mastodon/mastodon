import escapeTextContentForBrowser from 'escape-html';
import emojify from '../../features/emoji/emoji';
import { unescapeHTML } from '../../utils/html';
import { expandSpoilers } from '../../initial_state';

const domParser = new DOMParser();

const makeEmojiMap = record => record.emojis.reduce((obj, emoji) => {
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

  const emojiMap = makeEmojiMap(account);
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

export function normalizeStatus(status, normalOldStatus) {
  const normalStatus   = { ...status };
  normalStatus.account = status.account.id;

  if (status.reblog && status.reblog.id) {
    normalStatus.reblog = status.reblog.id;
  }

  if (status.poll && status.poll.id) {
    normalStatus.poll = status.poll.id;
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
    normalStatus.quote = normalOldStatus.get('quote');
    normalStatus.quote_hidden = normalOldStatus.get('quote_hidden');
  } else {
    // If the status has a CW but no contents, treat the CW as if it were the
    // status' contents, to avoid having a CW toggle with seemingly no effect.
    if (normalStatus.spoiler_text && !normalStatus.content) {
      normalStatus.content = normalStatus.spoiler_text;
      normalStatus.spoiler_text = '';
    }

    const spoilerText   = normalStatus.spoiler_text || '';
    const searchContent = ([spoilerText, status.content].concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])).concat(status.media_attachments.map(att => att.description)).join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');
    const emojiMap      = makeEmojiMap(normalStatus);

    normalStatus.search_index = domParser.parseFromString(searchContent, 'text/html').documentElement.textContent;
    normalStatus.contentHtml  = emojify(normalStatus.content, emojiMap);
    normalStatus.spoilerHtml  = emojify(escapeTextContentForBrowser(spoilerText), emojiMap);
    normalStatus.hidden       = expandSpoilers ? false : spoilerText.length > 0 || normalStatus.sensitive;

    if (status.quote && status.quote.id) {
      const quote_spoilerText = status.quote.spoiler_text || '';
      const quote_searchContent = [quote_spoilerText, status.quote.content].join('\n\n').replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');

      const quote_emojiMap = makeEmojiMap(normalStatus.quote);

      const quote_account_emojiMap = makeEmojiMap(status.quote.account);
      const displayName = normalStatus.quote.account.display_name.length === 0 ? normalStatus.quote.account.username : normalStatus.quote.account.display_name;
      normalStatus.quote.account.display_name_html = emojify(escapeTextContentForBrowser(displayName), quote_account_emojiMap);
      normalStatus.quote.search_index = domParser.parseFromString(quote_searchContent, 'text/html').documentElement.textContent;
      let docElem = domParser.parseFromString(normalStatus.quote.content, 'text/html').documentElement;
      Array.from(docElem.querySelectorAll('p,br'), line => {
        let parentNode = line.parentNode;
        if (line.nextSibling) {
          parentNode.insertBefore(document.createTextNode(' '), line.nextSibling);
        }
      });
      // TODO: how to use normalOldStatus?
      // let _contentHtml = docElem.textContent;
      // normalStatus.quote.contentHtml  = '<p>'+emojify(_contentHtml.substr(0, 150), quote_emojiMap) + (_contentHtml.substr(150) ? '...' : '')+'</p>';
      let _contentHtml = docElem.innerHTML;
      normalStatus.quote.contentHtml  = '<p>'+emojify(_contentHtml, quote_emojiMap)+'</p>';
      normalStatus.quote.spoilerHtml  = emojify(escapeTextContentForBrowser(quote_spoilerText), quote_emojiMap);
      normalStatus.quote_hidden       = expandSpoilers ? false : quote_spoilerText.length > 0 || normalStatus.quote.sensitive;
    }
  }

  return normalStatus;
}

export function normalizePoll(poll) {
  const normalPoll = { ...poll };
  const emojiMap = makeEmojiMap(normalPoll);

  normalPoll.options = poll.options.map((option, index) => ({
    ...option,
    voted: poll.own_votes && poll.own_votes.includes(index),
    title_emojified: emojify(escapeTextContentForBrowser(option.title), emojiMap),
  }));

  return normalPoll;
}

export function normalizeAnnouncement(announcement) {
  const normalAnnouncement = { ...announcement };
  const emojiMap = makeEmojiMap(normalAnnouncement);

  normalAnnouncement.contentHtml = emojify(normalAnnouncement.content, emojiMap);

  return normalAnnouncement;
}
