import type React from 'react';
import { useCallback, useMemo } from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { selectExpandedStatus } from '@/mastodon/selectors/statuses';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import { ContentWarning } from '../content_warning';
import { FilterWarning } from '../filter_warning';
import { computeHashtagBarForStatus, HashtagBar } from '../hashtag_bar';
import { Hotkeys } from '../hotkeys';

import { StatusActionBar } from './action_bar';
import { StatusAttachments } from './attachments';
import { StatusContent } from './content';
import { StatusHeader } from './header';
import type { StatusHandlers } from './hooks';
import { useStatusHandlers, useTextForScreenReader } from './hooks';
import { StatusPrepend } from './prepend';
import type { StatusContainerProps, StatusContextType } from './types';

type StatusRedesignProps = Merge<
  Omit<StatusContainerProps, 'account'>,
  {
    accountId?: string;
    contextType?: StatusContextType;
    onClick?: () => void;
  }
>;

const selectStatusReblog = createAppSelector(
  [(state, id?: string | null) => selectExpandedStatus(state, id ?? undefined)],
  (status) => {
    if (!status) {
      return {};
    }
    if (!status.reblog) {
      return { status };
    }

    const { reblog, ...statusRest } = status;
    return {
      status: reblog,
      parent: statusRest,
    };
  },
);

export const StatusRedesign: React.FC<StatusRedesignProps> = ({
  id,
  muted,
  rootId,
  previousId,
  nextId,
  unread,
  skipPrepend,
  unfocusable,
  contextType,
  featured,
  isQuotedPost,
  accountId,
  hidden,
  shouldHighlightOnMount,
  showActions,
  scrollKey,
  children,
  headerRenderFn,
  avatarSize,
  withCounters,
  withDismiss,
  onClick,
  showThread,
}) => {
  // Select data from store
  const { status, parent } = useAppSelector((state) =>
    selectStatusReblog(state, id),
  );
  const account = useAppSelector(
    (state) =>
      parent?.account ?? selectPlainAccount(state, accountId) ?? undefined,
  );
  const matchedFilters = useAppSelector((state) =>
    selectStatusFilters(state, { contextType, statusId: parent?.id ?? id }),
  );
  const statusId = status?.id;

  // Display
  const screenReaderText = useTextForScreenReader({
    statusId,
    reblogAcct: parent?.account.acct,
    isQuote: isQuotedPost,
  });
  const { statusContent, hashtagsInBar } = useMemo(
    (): Partial<ReturnType<typeof computeHashtagBarForStatus>> =>
      status ? computeHashtagBarForStatus(status) : {},
    [status],
  );

  // Handlers
  const {
    showDespiteFilter,
    onHeaderClick,
    onExpandedToggle,
    onFilterToggle,
    onOpenClick,
    onTranslate,
    ...handlers
  } = useStatusHandlers({ status, contextType, onClick });

  if (!status) {
    return null; // loading state
  }

  const actualStatus = parent ?? status;

  const expanded =
    (matchedFilters.length === 0 || showDespiteFilter) &&
    (!status.hidden || !status.spoiler_text);

  const hotkeysProps = {
    ...handlers,
    onTranslate,
    muted,
    unfocusable,
  } satisfies Omit<React.ComponentProps<typeof StatusHotkeys>, 'children'>;

  if (hidden) {
    return (
      <StatusHotkeys {...hotkeysProps}>
        <div
          className={classNames('status__wrapper', { focusable: !muted })}
          tabIndex={unfocusable ? undefined : 0}
        >
          <span>{status.account.display_name || status.account.username}</span>
          {status.spoiler_text && <span>{status.spoiler_text}</span>}
          {expanded && <span>{status.content}</span>}
        </div>
      </StatusHotkeys>
    );
  }

  const header = headerRenderFn ? (
    headerRenderFn({
      statusId: status.id,
      account,
      avatarSize,
      onHeaderClick,
      featured,
    })
  ) : (
    <StatusHeader
      statusId={status.id}
      account={account}
      avatarSize={avatarSize}
      onHeaderClick={onHeaderClick}
    />
  );

  return (
    <StatusHotkeys {...hotkeysProps}>
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
        {!skipPrepend && (
          <StatusPrepend
            status={actualStatus}
            isReblog={!!parent}
            showThread={showThread}
          />
        )}
        <StatusContentWrapper
          statusId={status.id}
          inReplyToId={actualStatus.in_reply_to_id}
          rootId={rootId}
          nextId={nextId}
          previousId={previousId}
          className={classNames(`status-${status.visibility}`, {
            muted,
            'status--is-quote': isQuotedPost,
            'status--has-quote': !!status.quote,
            'status--highlighted-entry': shouldHighlightOnMount,
          })}
        >
          {header}

          {matchedFilters.length > 0 && (
            <FilterWarning
              title={matchedFilters.map((filter) => filter.title).join(', ')}
              expanded={showDespiteFilter}
              onClick={onFilterToggle}
            />
          )}

          {(matchedFilters.length === 0 || showDespiteFilter) && (
            <ContentWarning
              statusId={status.id}
              expanded={expanded}
              onClick={onExpandedToggle}
            />
          )}

          {expanded && (
            <>
              <StatusContent
                statusId={status.id}
                statusContent={statusContent}
                onClick={onOpenClick}
                onTranslate={onTranslate}
                collapsible
              />

              <StatusAttachments
                statusId={status.id}
                contextType={contextType}
              />

              {hashtagsInBar && (
                <HashtagBar
                  hashtags={hashtagsInBar}
                  accountId={status.account.id}
                />
              )}

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
        </StatusContentWrapper>
      </div>
    </StatusHotkeys>
  );
};

const StatusHotkeys: React.FC<
  {
    muted?: boolean;
    unfocusable?: boolean;
    children: React.ReactNode;
  } & Omit<
    StatusHandlers,
    | 'showDespiteFilter'
    | 'onOpenClick'
    | 'onHeaderClick'
    | 'onExpandedToggle'
    | 'onFilterToggle'
  >
> = ({ muted, unfocusable, children, ...handlers }) => {
  const onOpen = useCallback(() => {
    handlers.onOpen();
  }, [handlers]);

  if (muted) {
    return children;
  }

  return (
    <Hotkeys
      handlers={{
        reply: handlers.onReply,
        favourite: handlers.onFavourite,
        boost: handlers.onBoost,
        quote: handlers.onQuote,
        mention: handlers.onMention,
        open: onOpen,
        openProfile: handlers.onOpenProfile,
        toggleHidden: handlers.onToggleHidden,
        // TODO: This is handled in a child component, so needs to be fixed.
        // toggleSensitive: onMediaShowToggle,
        openMedia: handlers.onOpenMedia,
        onTranslate: handlers.onTranslate,
      }}
      focusable={!unfocusable}
    >
      {children}
    </Hotkeys>
  );
};

const StatusContentWrapper: React.FC<
  Pick<StatusRedesignProps, 'rootId' | 'previousId' | 'nextId' | 'children'> & {
    statusId: string;
    inReplyToId?: string;
    className?: string;
  }
> = ({
  statusId,
  inReplyToId,
  rootId,
  previousId,
  nextId,
  className,
  children,
}) => {
  const nextInReplyToId = useAppSelector((state) =>
    nextId ? state.statuses.getIn([nextId, 'in_reply_to_id']) : null,
  );
  const connectUp = !!previousId && previousId === inReplyToId;
  const connectToRoot = !!rootId && rootId === inReplyToId;
  const connectReply = !!nextInReplyToId && nextInReplyToId === statusId;
  return (
    <div
      className={classNames(
        'status',
        {
          'status-reply': !!inReplyToId,
          'status--in-thread': !!rootId,
          'status--first-in-thread':
            previousId && (!connectUp || connectToRoot),
        },
        className,
      )}
      data-id={statusId}
    >
      {(connectReply || connectUp || connectToRoot) && (
        <div
          className={classNames('status__line', {
            'status__line--full': connectReply,
            'status__line--first': !inReplyToId && !connectToRoot,
          })}
        />
      )}

      {children}
    </div>
  );
};
