import { useCallback, useId, useMemo, useState } from 'react';

import classNames from 'classnames';

import type { Merge } from 'type-fest';

import type { ExpandedStatusShape } from '@/mastodon/models/status';
import { selectStatusLoadingState } from '@/mastodon/selectors/statuses';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

import type {
  HotkeyHandlerFunction,
  HotkeyHandlerMap,
  HotkeyName,
} from '../hotkeys';
import { Hotkeys } from '../hotkeys';
import { Poll } from '../poll';

import { StatusActionBar } from './action_bar';
import { StatusAttachments } from './attachments';
import { StatusContent } from './content';
import { StatusHashtagBar } from './hashtag_bar';
import { StatusRedesignHeader } from './header';
import {
  StatusContext,
  useStatusContext,
  useStatusHandlers,
  useTextForScreenReader,
} from './hooks';
import { computeHashtagBarForStatus } from './legacy/hashtag_bar';
import { StatusMeta } from './meta';
import { StatusPrepend } from './prepend';
import classes from './styles.module.scss';
import { TranslateButton } from './translate';
import type { StatusContainerProps, StatusContextType } from './types';
import { StatusWarning } from './warning';

type StatusRedesignProps = Merge<
  Omit<StatusContainerProps, 'account'>,
  {
    accountId?: string;
    contextType?: StatusContextType;
    headerContents?: React.ReactNode;
    variant?: StatusVariant;
  }
>;

export type StatusVariant = 'feed' | 'thread' | 'page';

const selectStatusReblog = createAppSelector(
  [
    (
      state,
      {
        statusId,
        contextType,
      }: { statusId?: string | null; contextType?: StatusContextType },
    ) => selectStatusLoadingState(state, { statusId, contextType }),
  ],
  ({ status, state }) => {
    if (!status) {
      return { state };
    }
    if (!status.reblog) {
      return { status, state };
    }

    const { reblog, ...statusRest } = status;
    return {
      status: reblog,
      parent: statusRest,
      state,
    };
  },
);

export const StatusRedesign: React.FC<StatusRedesignProps> = ({
  id,
  muted,
  skipPrepend,
  unfocusable,
  contextType,
  featured,
  isQuotedPost,
  hidden,
  showActions = true,
  children,
  withCounters = true,
  withDismiss,
  onOpen,
  showThread,
  shouldHighlightOnMount,
  headerContents,
  variant = contextToVariant(contextType),
  nextId,
}) => {
  // Select data from store
  const { status, parent } = useAppSelector((state) =>
    selectStatusReblog(state, { statusId: id, contextType }),
  );
  const statusId = status?.id;

  // Display
  const screenReaderText = useTextForScreenReader({
    statusId,
    reblogAcct: parent?.account.acct,
    isQuote: isQuotedPost,
  });
  const { statusContent, hashtagsInBar = [] } = useMemo(
    (): Partial<ReturnType<typeof computeHashtagBarForStatus>> =>
      status ? computeHashtagBarForStatus(status) : {},
    [status],
  );
  const contentWrapperId = useId();

  const isNextReplyingToMe = useAppSelector(
    (state) => state.statuses.getIn([nextId, 'in_reply_to_id']) === statusId,
  );

  // Handlers
  const {
    isFiltered,
    showDespiteFilter,
    onFilterToggle,
    onTranslate,
    onOpenCallback,
    onOpenClick,
  } = useStatusHandlers({
    status,
    contextType,
    onOpen,
  });

  const [hotkeyHandlers, setHotkeyHandlers] = useState<HotkeyHandlerMap>({});
  const registerHotkey = useCallback(
    (hotkey: HotkeyName, handler: HotkeyHandlerFunction) => {
      setHotkeyHandlers((prev) => ({ ...prev, [hotkey]: handler }));
    },
    [],
  );

  if (!status) {
    return null; // loading state
  }

  const hotkeysProps = {
    status,
    onOpen,
    muted,
    unfocusable,
    'data-id': id,
    handlers: hotkeyHandlers,
  };

  const isHidden =
    (!showDespiteFilter && isFiltered) ||
    (!!status.spoiler_text && status.hidden);

  if (hidden) {
    return (
      <StatusHotkeys {...hotkeysProps}>
        <span>{status.account.display_name || status.account.username}</span>
        {status.spoiler_text && <span>{status.spoiler_text}</span>}
        {!isHidden && <span>{status.content}</span>}
      </StatusHotkeys>
    );
  }

  return (
    <StatusContext.Provider
      value={{ id, contextType, registerHotkeyCallback: registerHotkey }}
    >
      <StatusHotkeys
        {...hotkeysProps}
        onClick={onOpenClick}
        className={classNames(
          classes.root,
          variant === 'feed' && classes.variantFeed,
          variant === 'thread' && classes.variantThread,
          variant === 'page' && classes.variantPage,
          isQuotedPost && classes.isQuote,
          shouldHighlightOnMount && classes.isHighlighted,
          status.visibility === 'direct' && classes.isMessage,
          variant === 'thread' &&
            isNextReplyingToMe &&
            !showThread &&
            classes.connectNextReply,
          !unfocusable && 'focusable',
        )}
        tabIndex={unfocusable ? undefined : -1}
        data-featured={featured ? 'true' : null}
        aria-label={screenReaderText}
        data-nosnippet={status.account.noindex || undefined}
        data-connect-next={nextId ? isNextReplyingToMe : undefined}
      >
        {!skipPrepend && (
          <StatusPrepend
            status={status}
            reblogId={parent?.id}
            showThread={showThread}
          />
        )}

        <StatusRedesignHeader status={status} className={classes.header}>
          {headerContents}
        </StatusRedesignHeader>

        <TranslateButton status={status} onTranslate={onTranslate} />

        <StatusWarning
          statusId={status.id}
          dismissedFilter={showDespiteFilter}
          onFilterToggle={onFilterToggle}
          wrapperId={contentWrapperId}
        />

        <div
          className={classNames(
            classes.contentWrapper,
            isHidden && classes.hasContentWarning,
            !showDespiteFilter && isFiltered && classes.isFiltered,
          )}
          id={contentWrapperId}
          inert={isHidden}
        >
          <StatusContent
            status={status}
            statusContent={statusContent}
            onReadMore={onOpenCallback}
            onTranslate={onTranslate}
            collapsible={variant !== 'page'}
          >
            {!!status.poll && (
              <Poll
                pollId={status.poll}
                statusUrl={status.uri}
                accountId={status.account.id}
                lang={status.translation?.language ?? status.language}
              />
            )}

            <StatusAttachments statusId={status.id} />

            {children}
          </StatusContent>

          <StatusHashtagBar
            hashtags={hashtagsInBar}
            accountId={status.account.id}
          />
        </div>

        {(variant === 'page' || (showActions && !isQuotedPost)) && (
          <footer className={classes.footer}>
            {showActions && !isQuotedPost && (
              <StatusActionBar
                statusId={status.id}
                withDismiss={withDismiss}
                withCounters={withCounters}
                onlyResponses={variant === 'page'}
              />
            )}

            {variant === 'page' && <StatusMeta status={status} />}
          </footer>
        )}
      </StatusHotkeys>
    </StatusContext.Provider>
  );
};

interface StatusHotkeysProps {
  children: React.ReactNode;
  status: ExpandedStatusShape;
  handlers: HotkeyHandlerMap;
  onOpen?: () => void;
  muted?: boolean;
  unfocusable?: boolean;
}

const StatusHotkeys = ({
  children,
  status,
  onOpen,
  muted,
  unfocusable,
  handlers: registeredHandlers,
  ...props
}: StatusHotkeysProps & React.ComponentPropsWithoutRef<'article'>) => {
  const { contextType } = useStatusContext();
  const handlers = useStatusHandlers({
    status,
    contextType,
    onOpen,
  });

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
        open: handlers.onOpenCallback,
        openProfile: handlers.onOpenProfile,
        toggleHidden: handlers.onToggleHidden,
        openMedia: handlers.onOpenMedia,
        onTranslate: handlers.onTranslate,
        ...registeredHandlers,
      }}
      focusable={!unfocusable}
    >
      {children}
    </Hotkeys>
  );
};

function contextToVariant(contextType?: StatusContextType): StatusVariant {
  switch (contextType) {
    case 'composer':
    case 'detailed':
    case undefined:
      return 'page';
    case 'thread':
      return 'thread';
    case 'notifications':
    default:
      return 'feed';
  }
}
