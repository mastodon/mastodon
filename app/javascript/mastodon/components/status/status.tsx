import type React from 'react';
import { useCallback, useMemo } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router';

import type { Merge } from 'type-fest';

import { mentionComposeById } from '@/mastodon/actions/compose';
import type { StatusInteractionIntent } from '@/mastodon/actions/interactions_typed';
import { statusInteraction } from '@/mastodon/actions/interactions_typed';
import { openModal } from '@/mastodon/actions/modal';
import { toggleStatusSpoilers } from '@/mastodon/actions/statuses';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { useToggle } from '@/mastodon/hooks/useToggle';
import type { ExpandedStatusShape } from '@/mastodon/models/status';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import type { FilterShape } from '@/mastodon/selectors/filters';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { selectExpandedStatus } from '@/mastodon/selectors/statuses';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';

import { ContentWarning } from '../content_warning';
import { LinkedDisplayName } from '../display_name';
import { FilterWarning } from '../filter_warning';
import { Hotkeys } from '../hotkeys';
import { Icon } from '../icon';
import { FOCUS_TARGET } from '../navigation_focus_target';
import { StatusThreadLabel } from '../status_thread_label';

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

export const StatusRedesign: React.FC<StatusRedesignProps> = (props) => {
  const {
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
  } = props;
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

  // State
  const [showDespiteFilter, { onToggle: onFilterToggle }] = useToggle(false);

  // Display
  const intl = useIntl();
  const screenReaderText = useTextForScreenReader({
    statusId: id,
    rebloggedByText: parent
      ? intl.formatMessage(messages.boosted, { name: parent.account.acct })
      : null,
    isQuote: isQuotedPost,
  });

  // Handlers
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

  if (!status) {
    return null; // loading state
  }

  const actualStatus = parent ?? status;

  const expanded =
    (matchedFilters.length === 0 || showDespiteFilter) &&
    (!status.hidden || !status.spoiler_text);

  const hotkeysProps = {
    status,
    matchedFilters,
    showDespiteFilter,
    muted,
    unfocusable,
    onFilterToggle,
    onClick,
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

              <StatusAttachments
                statusId={status.id}
                contextType={contextType}
              />
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
        </StatusContentWrapper>
      </div>
    </StatusHotkeys>
  );
};

const StatusHotkeys: React.FC<{
  status: ExpandedStatusShape;
  matchedFilters: FilterShape[];
  showDespiteFilter: boolean;
  onFilterToggle: () => void;
  muted?: boolean;
  unfocusable?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}> = ({
  status,
  matchedFilters,
  showDespiteFilter,
  onFilterToggle,
  muted,
  unfocusable,
  onClick,
  children,
}) => {
  const dispatch = useAppDispatch();
  const history = useHistory();

  const handlerFactory = useCallback(
    (intent: StatusInteractionIntent) => {
      return () => {
        dispatch(statusInteraction({ statusId: status.id, intent }));
      };
    },
    [dispatch, status.id],
  );
  const handleMention = useCallback(() => {
    dispatch(mentionComposeById(status.account.id));
  }, [dispatch, status.account.id]);
  const handleOpen = useCallback(() => {
    if (onClick) {
      onClick();
      return;
    }

    const path = `/@${status.account.acct}/${status.id}`;

    if (history.location.pathname.replace('/deck/', '/') === path) {
      history.replace(path, { focusTarget: FOCUS_TARGET.POST });
    } else {
      history.push(path, { focusTarget: FOCUS_TARGET.POST });
    }
  }, [history, onClick, status.account.acct, status.id]);
  const handleOpenProfile = useCallback(() => {
    history.push(`/@${status.account.acct}`);
  }, [history, status.account.acct]);
  const handleToggleHidden = useCallback(() => {
    if (!matchedFilters.length || showDespiteFilter) {
      dispatch(toggleStatusSpoilers(status.id));
    }

    if (!status.hidden || !status.spoiler_text) {
      onFilterToggle();
    }
  }, [
    dispatch,
    matchedFilters.length,
    onFilterToggle,
    showDespiteFilter,
    status,
  ]);
  const handleOpenMedia = useCallback(() => {
    const attachment = status.media_attachments[0];
    if (!attachment) {
      return;
    }

    const lang = status.translation?.language ?? status.language;
    if (attachment.type === 'video') {
      dispatch(
        openModal({
          modalType: 'VIDEO',
          modalProps: {
            statusId: status.id,
            media: attachment,
            lang,
            options: { startTime: 0 },
          },
        }),
      );
    } else {
      dispatch(
        openModal({
          modalType: 'MEDIA',
          modalProps: {
            statusId: status.id,
            media: status.media_attachments,
            lang,
            index: 0,
          },
        }),
      );
    }
  }, [dispatch, status]);

  if (muted) {
    return children;
  }

  return (
    <Hotkeys
      handlers={{
        reply: handlerFactory('reply'),
        favourite: handlerFactory('favourite'),
        boost: handlerFactory('reblog'),
        quote: handlerFactory('quote'),
        mention: handleMention,
        open: handleOpen,
        openProfile: handleOpenProfile,
        toggleHidden: handleToggleHidden,
        // TODO: This is handled in a child component, so needs to be fixed.
        // toggleSensitive: onMediaShowToggle,
        openMedia: handleOpenMedia,
        onTranslate: handlerFactory('translate'),
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

const StatusPrepend: React.FC<{
  status: ExpandedStatusShape;
  showThread?: boolean;
  isReblog?: boolean;
}> = ({ status, showThread, isReblog }) => {
  if (isReblog) {
    return (
      <div className='status__prepend'>
        <div className='status__prepend__icon'>
          <Icon id='retweet' icon={RepeatIcon} />
        </div>
        <FormattedMessage
          id='status.reblogged_by'
          defaultMessage='{name} boosted'
          values={{
            name: (
              <LinkedDisplayName
                displayProps={{
                  account: status.account,
                  variant: 'simple',
                }}
                className='status__display-name muted'
              />
            ),
          }}
          tagName='span'
        />
      </div>
    );
  }

  if (status.visibility === 'direct') {
    return (
      <div className='status__prepend'>
        <div className='status__prepend__icon'>
          <Icon id='at' icon={AlternateEmailIcon} />
        </div>
        <FormattedMessage
          id='status.direct_indicator'
          defaultMessage='Private mention'
          tagName='span'
        />
      </div>
    );
  }

  if (showThread && status.in_reply_to_account_id) {
    return (
      <StatusThreadLabel
        accountId={status.account.id}
        inReplyToAccountId={status.in_reply_to_account_id}
      />
    );
  }

  return null;
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
