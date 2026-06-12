import escapeTextContentForBrowser from 'escape-html';

import type { ApiMediaAttachmentJSON } from '@/mastodon/api_types/media_attachments';
import type {
  ApiFilterResultJSON,
  ApiStatusJSON,
} from '@/mastodon/api_types/statuses';
import type {
  FilterResult,
  MediaAttachmentShape,
  StatusShape,
} from '@/mastodon/models/status';

const domParser = new DOMParser();

export function normalizeStatus(
  status: ApiStatusJSON,
  normalOldStatus?: StatusShape,
  { bogusQuotePolicy = false, expandSpoilers = false } = {},
) {
  const normalStatus: StatusShape = {
    hidden: normalOldStatus?.hidden ?? false,
    collapsed: normalOldStatus?.collapsed ?? false,
    content: '',
    contentHtml: '',
    muted: false,
    pinned: false,
    bookmarked: false,
    favourited: false,
    quote_approval: null,
    reblogged: false,

    ...status,

    account: status.account.id,
    media_attachments: [],
    poll: status.poll?.id,
    reblog: status.reblog?.id,
    quote: undefined,
    filtered: [],
    application: {
      name: 'Web',
      ...status.application,
    },
  };

  if (bogusQuotePolicy) {
    normalStatus.quote_approval = null;
  }

  if (status.quote?.quoted_status) {
    normalStatus.quote = {
      ...status.quote,
      quoted_status: status.quote.quoted_status.id,
    };
  }

  if (status.card) {
    normalStatus.card = {
      ...status.card,
      authors: status.card.authors.map((author) => ({
        name: author.name,
        url: author.url,
        accountId: author.account?.id,
      })),
    };
  }

  if (status.filtered) {
    normalStatus.filtered = status.filtered.map(normalizeFilterResult);
  }

  // Only calculate these values when status first encountered and
  // when the underlying values change. Otherwise keep the ones
  // already in the reducer
  if (
    normalOldStatus?.content === normalStatus.content &&
    normalOldStatus.spoiler_text === normalStatus.spoiler_text
  ) {
    normalStatus.search_index = normalOldStatus.search_index;
    normalStatus.contentHtml = normalOldStatus.contentHtml;
    normalStatus.spoilerHtml = normalOldStatus.spoilerHtml;
    normalStatus.spoiler_text = normalOldStatus.spoiler_text;
    normalStatus.hidden = normalOldStatus.hidden;

    if (normalOldStatus.translation) {
      normalStatus.translation = normalOldStatus.translation;
    }
  } else {
    // If the status has a CW but no contents, treat the CW as if it were the
    // status' contents, to avoid having a CW toggle with seemingly no effect.
    if (
      normalStatus.spoiler_text &&
      !normalStatus.content &&
      !normalStatus.quote
    ) {
      normalStatus.content = normalStatus.spoiler_text;
      normalStatus.spoiler_text = '';
    }

    const spoilerText = normalStatus.spoiler_text ?? '';
    const searchContent = [spoilerText, status.content]
      .concat(
        status.poll?.options
          ? status.poll.options.map((option) => option.title)
          : [],
      )
      .concat(status.media_attachments.map((att) => att.description))
      .join('\n\n')
      .replace(/<br\s*\/?>/g, '\n')
      .replace(/<\/p><p>/g, '\n\n');

    normalStatus.search_index = domParser.parseFromString(
      searchContent,
      'text/html',
    ).documentElement.textContent;
    normalStatus.contentHtml = normalStatus.content;
    normalStatus.spoilerHtml = escapeTextContentForBrowser(spoilerText);
    normalStatus.hidden = expandSpoilers
      ? false
      : spoilerText.length > 0 || normalStatus.sensitive;

    // Remove quote fallback link from the DOM so it doesn't mess with paragraph margins
    if (normalStatus.quote && normalStatus.contentHtml) {
      normalStatus.contentHtml = stripQuoteFallback(normalStatus.contentHtml);
    }

    if (
      normalStatus.url &&
      !(
        normalStatus.url.startsWith('http://') ||
        normalStatus.url.startsWith('https://')
      )
    ) {
      normalStatus.url = null;
    }

    normalStatus.url ??= normalStatus.uri;

    normalStatus.media_attachments = status.media_attachments.map(
      (attachment) =>
        normalizeMediaAttachment(
          attachment,
          normalOldStatus?.media_attachments,
        ),
    );
  }

  if (normalOldStatus) {
    normalStatus.quote_approval ??= normalOldStatus.quote_approval;
  }

  return normalStatus;
}

function normalizeMediaAttachment(
  attachment: ApiMediaAttachmentJSON,
  oldAttachments?: MediaAttachmentShape[],
): MediaAttachmentShape {
  const { remote_url } = attachment;
  return {
    ...attachment,
    remote_url:
      remote_url && /^https?:\/\//.test(remote_url) ? remote_url : null,
    translation: oldAttachments?.find(
      (oldAttachment) =>
        oldAttachment.id === attachment.id &&
        oldAttachment.description === attachment.description,
    )?.translation,
  };
}

function normalizeFilterResult(input: ApiFilterResultJSON): FilterResult {
  return {
    ...input,
    filter: input.filter.id,
  };
}

function stripQuoteFallback(text: string) {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = text;

  wrapper.querySelector('.quote-inline')?.remove();

  return wrapper.innerHTML;
}
