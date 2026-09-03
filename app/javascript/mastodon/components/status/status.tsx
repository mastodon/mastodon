import { useMemo } from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

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
import type { StatusHandlers } from './hooks';
import { useStatusHandlers, useTextForScreenReader } from './hooks';
import { StatusPrepend } from './prepend';
import { StatusRedesignHeader } from './redesign/header';
import classes from './styles.module.scss';
import type { StatusContainerProps, StatusContextType } from './types';

type StatusRedesignProps = Merge<
  Omit<StatusContainerProps, 'account'>,
  {
    accountId?: string;
    contextType?: StatusContextType;
    headerContents?: React.ReactNode;
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
  unread,
  skipPrepend,
  unfocusable,
  contextType,
  featured,
  isQuotedPost,
  hidden,
  showActions = true,
  scrollKey,
  children,
  avatarSize = 40,
  withCounters,
  withDismiss,
  onOpen,
  showThread,
  headerContents,
}) => {
  // Select data from store
  const { status, parent } = useAppSelector((state) =>
    selectStatusReblog(state, id),
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
  } = useStatusHandlers({ status, contextType, onOpen });

  if (!status) {
    return null; // loading state
  }

  const actualStatus = parent ?? status;

  const expanded =
    (matchedFilters.length === 0 || showDespiteFilter) &&
    (!status.hidden || !status.spoiler_text);

  const hotkeysProps = {
    handlers: {
      ...handlers,
      onTranslate,
    },
    muted,
    unfocusable,
    'data-id': id,
  };

  if (hidden) {
    return (
      <StatusHotkeys
        {...hotkeysProps}
        className={classNames('status__wrapper', { focusable: !muted })}
      >
        <span>{status.account.display_name || status.account.username}</span>
        {status.spoiler_text && <span>{status.spoiler_text}</span>}
        {expanded && <span>{status.content}</span>}
      </StatusHotkeys>
    );
  }

  return (
    <StatusHotkeys
      {...hotkeysProps}
      className={classNames(
        classes.root,
        'status__wrapper',
        `status__wrapper-${status.visibility}`,
        {
          'status__wrapper-reply': !!status.in_reply_to_id,
          'status__wrapper--in-thread': !!rootId,
          unread,
          focusable: !muted,
        },
      )}
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

      <StatusRedesignHeader status={status} avatarSize={avatarSize}>
        {headerContents}
      </StatusRedesignHeader>

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

          <StatusAttachments statusId={status.id} contextType={contextType} />

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
    </StatusHotkeys>
  );
};

interface StatusHotkeysProps {
  muted?: boolean;
  unfocusable?: boolean;
  children: React.ReactNode;
  handlers: Omit<
    StatusHandlers,
    | 'showDespiteFilter'
    | 'onOpenClick'
    | 'onHeaderClick'
    | 'onExpandedToggle'
    | 'onFilterToggle'
  >;
}

const StatusHotkeys = ({
  muted,
  unfocusable,
  children,
  handlers,
  ...props
}: StatusHotkeysProps & React.ComponentPropsWithoutRef<'article'>) => {
  if (muted) {
    return <article {...props}>{children}</article>;
  }

  return (
    <Hotkeys
      {...props}
      as='article'
      handlers={{
        reply: handlers.onReply,
        favourite: handlers.onFavourite,
        boost: handlers.onBoost,
        quote: handlers.onQuote,
        mention: handlers.onMention,
        open: handlers.onOpen,
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
