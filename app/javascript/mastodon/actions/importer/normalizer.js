import escapeTextContentForBrowser from 'escape-html';
import sanitizeHtml from 'sanitize-html';

import { expandSpoilers } from '../../initial_state';
import { importCustomEmoji } from './emoji';

/**
 * Use sanitize-html to return only the visible, safe text from any HTML.
 */
function htmlToSearchText(html = '') {
  return sanitizeHtml(String(html), {
    allowedTags: [],
    allowedAttributes: {}
  });
}

export function searchTextFromRawStatus(status) {
  const spoilerText = status.spoiler_text || '';
  const searchContent = ([spoilerText, status.content]
    .concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])
    .concat(status.media_attachments.map(att => att.description))
  ).join('\n\n')
  .replace(/<br\s*\/?>/g, '\n')
  .replace(/<\/p><p>/g, '\n\n');
  return htmlToSearchText(searchContent);
}

export function normalizeFilterResult(result) {
  const normalResult = { ...result };
  normalResult.filter = normalResult.filter.id;
  return normalResult;
}

function stripQuoteFallback(text) {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = text;
  wrapper.querySelector('.quote-inline')?.remove();
  return wrapper.innerHTML;
}

export function normalizeStatus(status, normalOldStatus, { bogusQuotePolicy = false }) {
  const normalStatus = { ...status };

  if (bogusQuotePolicy)
    normalStatus.quote_approval = null;

  normalStatus.account = status.account.id;

  if (status.reblog && status.reblog.id) {
    normalStatus.reblog = status.reblog.id;
  }

  if (status.quote?.quoted_status ?? status.quote?.quoted_status_id) {
    normalStatus.quote = {
      ...status.quote,
      quoted_status: status.quote.quoted_status?.id ?? status.quote?.quoted_status_id,
    };
  }

  if (status.poll && status.poll.id) {
    normalStatus.poll = status.poll.id;
  }

  if (status.card) {
    normalStatus.card = {
      ...status.card,
      authors: status.card.authors.map(author => ({
        ...author,
        accountId: author.account?.id,
        account: undefined,
      })),
    };
  }

  if (status.filtered) {
    normalStatus.filtered = status.filtered.map(normalizeFilterResult);
  }

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
    if (normalStatus.spoiler_text && !normalStatus.content && !normalStatus.quote) {
      normalStatus.content = normalStatus.spoiler_text;
      normalStatus.spoiler_text = '';
    }

    const spoilerText = normalStatus.spoiler_text || '';
    const searchContent = ([spoilerText, status.content]
      .concat((status.poll && status.poll.options) ? status.poll.options.map(option => option.title) : [])
      .concat(status.media_attachments.map(att => att.description))
    ).join('\n\n')
    .replace(/<br\s*\/?>/g, '\n')
    .replace(/<\/p><p>/g, '\n\n');

    normalStatus.search_index = htmlToSearchText(searchContent);

    normalStatus.contentHtml = normalStatus.content;
    normalStatus.spoilerHtml = escapeTextContentForBrowser(spoilerText);
    normalStatus.hidden = expandSpoilers ? false : spoilerText.length > 0 || normalStatus.sensitive;

    if (normalStatus.quote) {
      normalStatus.contentHtml = stripQuoteFallback(normalStatus.contentHtml);
    }

    if (normalStatus.url && !(normalStatus.url.startsWith('http://') || normalStatus.url.startsWith('https://'))) {
      normalStatus.url = null;
    }
    normalStatus.url ||= normalStatus.uri;

    normalStatus.media_attachments.forEach(item => {
      if (item.remote_url && !(item.remote_url.startsWith('http://') || item.remote_url.startsWith('https://')))
        item.remote_url = null;
    });
  }

  if (normalOldStatus) {
    normalStatus.quote_approval ||= normalOldStatus.get('quote_approval');
    const list = normalOldStatus.get('media_attachments');
    if (normalStatus.media_attachments && list) {
      normalStatus.media_attachments.forEach(item => {
        const oldItem = list.find(i => i.get('id') === item.id);
        if (oldItem && oldItem.get('description') === item.description) {
          item.translation = oldItem.get('translation');
        }
      });
    }
  }

  return normalStatus;
}

export function normalizeStatusTranslation(translation, status) {
  const normalTranslation = {
    detected_source_language: translation.detected_source_language,
    language: translation.language,
    provider: translation.provider,
    contentHtml: translation.content,
    spoilerHtml: escapeTextContentForBrowser(translation.spoiler_text),
    spoiler_text: translation.spoiler_text,
  };

  if (status.get('quote')) {
    normalTranslation.contentHtml = stripQuoteFallback(normalTranslation.contentHtml);
  }

  return normalTranslation;
}

export function normalizeAnnouncement(announcement) {
  const normalAnnouncement = { ...announcement };
  normalAnnouncement.contentHtml = normalAnnouncement.content;
  if (normalAnnouncement.emojis) {
    importCustomEmoji(normalAnnouncement.emojis);
  }
  return normalAnnouncement;
}
