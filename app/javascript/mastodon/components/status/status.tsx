import { useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { useAppSelector } from '@/mastodon/store';

import { ContentWarning } from '../content_warning';
import { FilterWarning } from '../filter_warning';

import { StatusActionBar } from './action_bar';
import { StatusAttachments } from './attachments';
import { StatusContent } from './content';
import { StatusHeader } from './header';
import type { StatusContainerProps, StatusContextType } from './types';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: {
    id: 'privacy.unlisted.short',
    defaultMessage: 'Quiet public',
  },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  direct_short: {
    id: 'privacy.direct.short',
    defaultMessage: 'Specific people',
  },
  edited: { id: 'status.edited', defaultMessage: 'Edited {date}' },
  quote_noun: {
    id: 'status.quote_noun',
    defaultMessage: 'Quote',
    description: 'Quote as a noun',
  },
  contains_quote: {
    id: 'status.contains_quote',
    defaultMessage: 'Contains quote',
  },
  quote_cancel: { id: 'status.quote.cancel', defaultMessage: 'Cancel quote' },
  boosted: { id: 'status.reblogged_by', defaultMessage: '{name} boosted' },
});

type StatusRedesignProps = Merge<
  Omit<StatusContainerProps, 'account'>,
  {
    accountId?: string;
    contextType?: StatusContextType;
  }
>;

export const StatusRedesign: React.FC<StatusRedesignProps> = ({
  id,
  muted,
  rootId,
  unread,
  unfocusable,
  contextType,
  featured,
  isQuotedPost,
  previousId,
  accountId,
  shouldHighlightOnMount,
  showActions,
  scrollKey,
  children,
  headerRenderFn,
  avatarSize,
  withCounters,
  withDismiss,
}) => {
  const status = useExpandedStatus(id ?? undefined);
  const [expanded] = useToggle(false);
  const [showDespiteFilter] = useToggle(false);
  const matchedFilters = useAppSelector((state) =>
    selectStatusFilters(state, { contextType, statusId: id }),
  );
  const account = useAppSelector(
    (state) => selectPlainAccount(state, accountId) ?? undefined,
  );
  const handleClick = useCallback(() => {
    // Nothing
  }, []);
  const handleHeaderClick = useCallback(() => {
    // Nothing
  }, []);
  const handleExpandedToggle = useCallback(() => {
    // Nothing
  }, []);
  const handleFilterToggle = useCallback(() => {
    // Nothing
  }, []);
  const handleTranslate = useCallback(() => {
    // Nothing
  }, []);

  const intl = useIntl();
  const screenReaderText = useTextForScreenReader({
    statusId: id,
    rebloggedByText: status?.reblog
      ? intl.formatMessage(messages.boosted, { name: status.account.acct })
      : null,
    isQuote: isQuotedPost,
  });

  if (!status) {
    return null; // loading state
  }

  const connectUp = false as boolean;
  const connectToRoot = false as boolean;
  const connectReply = false as boolean;
  const hashtagBar = null;

  const header = headerRenderFn ? (
    headerRenderFn({
      statusId: status.id,
      account,
      avatarSize,
      onHeaderClick: handleHeaderClick,
      featured,
    })
  ) : (
    <StatusHeader
      statusId={status.id}
      account={account}
      avatarSize={avatarSize}
      onHeaderClick={handleHeaderClick}
    />
  );

  return (
    <div
      className={classNames(
        'status__wrapper',
        `status__wrapper-${status.visibility}`,
        {
          'status__wrapper-reply': !!status.in_reply_to_id,
          'status__wrapper--in-thread': !!rootId,
          unread,
          focusable: !muted,
        },
      )}
      tabIndex={muted || unfocusable ? undefined : 0}
      data-featured={featured ? 'true' : null}
      aria-label={screenReaderText}
      data-nosnippet={status.account.noindex || undefined}
    >
      <div
        className={classNames('status', `status-${status.visibility}`, {
          'status-reply': !!status.in_reply_to_id,
          'status--in-thread': !!rootId,
          'status--first-in-thread':
            previousId && (!connectUp || connectToRoot),
          muted: muted,
          'status--is-quote': isQuotedPost,
          'status--has-quote': !!status.quote,
          'status--highlighted-entry': shouldHighlightOnMount,
        })}
        data-id={status.id}
      >
        {(connectReply || connectUp || connectToRoot) && (
          <div
            className={classNames('status__line', {
              'status__line--full': connectReply,
              'status__line--first': !status.in_reply_to_id && !connectToRoot,
            })}
          />
        )}

        {header}

        {matchedFilters.length > 0 && (
          <FilterWarning
            title={matchedFilters.map((filter) => filter.title).join(', ')}
            expanded={showDespiteFilter}
            onClick={handleFilterToggle}
          />
        )}

        {(matchedFilters.length === 0 || showDespiteFilter) && (
          <ContentWarning
            statusId={status.id}
            expanded={expanded}
            onClick={handleExpandedToggle}
          />
        )}

        {expanded && (
          <>
            <StatusContent
              statusId={status.id}
              onClick={handleClick}
              onTranslate={handleTranslate}
              collapsible
            />

            <StatusAttachments statusId={status.id} contextType={contextType} />
            {hashtagBar}

            {children}
          </>
        )}

        {showActions && !isQuotedPost && (
          <StatusActionBar
            scrollKey={scrollKey}
            statusId={status.id}
            contextType={contextType}
            withDismiss={withDismiss}
            withCounters={withCounters}
          />
        )}
      </div>
    </div>
  );
};

const domParser = new DOMParser();

export function useTextForScreenReader({
  statusId,
  rebloggedByText,
  isQuote = false,
}: {
  statusId?: string | null;
  rebloggedByText?: string | null;
  isQuote?: boolean;
}) {
  const intl = useIntl();
  const status = useExpandedStatus(statusId);
  return useMemo(() => {
    if (!status) {
      return '';
    }
    const displayName = status.account.display_name;

    const spoilerText = status.translation?.spoiler_text ?? status.spoiler_text;
    const contentHtml = status.translation?.contentHtml ?? status.contentHtml;
    const contentText = domParser.parseFromString(contentHtml, 'text/html')
      .documentElement.textContent;

    const values = [
      isQuote ? intl.formatMessage(messages.quote_noun) : undefined,
      displayName.length === 0
        ? status.account.acct.split('@')[0]
        : displayName,
      spoilerText && status.hidden ? spoilerText : contentText,
      status.quote ? intl.formatMessage(messages.contains_quote) : undefined,
      intl.formatDate(status.created_at, {
        hour: '2-digit',
        minute: '2-digit',
        month: 'short',
        day: 'numeric',
      }),
      status.account.acct,
      rebloggedByText,
    ].filter((val) => !!val);

    return values.join(', ');
  }, [intl, isQuote, rebloggedByText, status]);
}
