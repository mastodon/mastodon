import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  ArrowsClockwiseIcon,
  BookmarkSimpleIcon,
  ChatCircleIcon,
  DotsThreeIcon,
  HeartIcon,
  QuotesIcon,
  ShareFatIcon,
} from '@phosphor-icons/react';

import { statusInteraction } from '@/mastodon/actions/interactions';
import { fetchStatus } from '@/mastodon/actions/statuses';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import { quickBoosting } from '@/mastodon/initial_state';
import type { AccountStatusShape } from '@/mastodon/models/status';
import { selectStatusConditions } from '@/mastodon/selectors/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import {
  Button,
  IconButton,
  ToggleButton,
  ToggleIconButton,
} from '../button/redesign';
import { iconWeight, useIconWeight } from '../icon';
import {
  Menu,
  MenuItem,
  MenuList,
  MenuTrigger,
  LegacyDropdownMenuItems,
} from '../menu';

import { boostItemState, quoteItemState } from './boost_button_utils';
import { useStatusContext, useStatusMenuActions } from './hooks';
import { RemoveQuoteHint } from './legacy/action_bar/remove_quote_hint';
import classes from './styles.module.scss';

interface StatusActionBarProps {
  statusId: string;
  withDismiss?: boolean;
  withCounters?: boolean;
  /** Only show methods to respond (reply, boost, like) and not sharing, bookmarking, and the overflow menu. */
  onlyResponses?: boolean;
}

const messages = defineMessages({
  replyAll: { id: 'status.replyAll', defaultMessage: 'Reply to thread' },
  favourite: { id: 'status.like', defaultMessage: 'Like' },
  removeFavourite: {
    id: 'status.unlike',
    defaultMessage: 'Unlike',
  },
});

export const StatusActionBar: React.FC<StatusActionBarProps> = ({
  statusId,
  withDismiss,
  withCounters,
  onlyResponses,
}) => {
  const status = useAccountStatus(statusId);
  const quotedAccountId = useAppSelector(
    (state) =>
      state.statuses.getIn([status?.quote?.quoted_status, 'account']) ?? null,
  );
  const currentAccountId = useCurrentAccountId();
  const { contextType } = useStatusContext();
  const statusUrl = status?.url ?? status?.uri;

  // Actions
  const dispatch = useAppDispatch();
  const handleReplyClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'reply', contextType }));
  }, [contextType, dispatch, statusId]);
  const handleFavouriteClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'favourite', contextType }));
  }, [contextType, dispatch, statusId]);
  const handleShareClick = useCallback(() => {
    if (!statusUrl) {
      return;
    }

    // We need to make this partial as by default share always is set, despite not being supported in FF.
    const nav = navigator as Partial<Pick<Navigator, 'share'>> &
      Pick<Navigator, 'clipboard'>;
    if (nav.share) {
      void nav.share({
        url: statusUrl,
      });
    } else {
      dispatch(statusInteraction({ statusId, intent: 'copy', contextType }));
    }
  }, [contextType, dispatch, statusId, statusUrl]);
  const handleBookmarkClick = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'bookmark', contextType }));
  }, [contextType, dispatch, statusId]);

  const intl = useIntl();

  const favouriteIcon = useIconWeight(HeartIcon, status?.favourited && 'fill');
  const bookmarkIcon = useIconWeight(
    BookmarkSimpleIcon,
    status?.bookmarked && 'fill',
  );

  if (!status) {
    return null;
  }

  const isPublic =
    status.visibility === 'public' || status.visibility === 'unlisted';

  const favouriteTitle = intl.formatMessage(
    status.favourited ? messages.removeFavourite : messages.favourite,
  );

  const isQuotingMe = quotedAccountId === currentAccountId;
  const shouldShowQuoteRemovalHint =
    isQuotingMe && contextType === 'notifications';

  const responseButtons = (
    <>
      <Button
        size='sm'
        clipPadding
        variant='ghost'
        title={intl.formatMessage(messages.replyAll)}
        leadingIcon={ChatCircleIcon}
        onClick={handleReplyClick}
      >
        {withCounters && status.replies_count}
      </Button>

      <StatusReblogButton statusId={statusId}>
        {withCounters && status.reblogs_count}
      </StatusReblogButton>

      <ToggleButton
        size='sm'
        variant='ghost'
        active={status.favourited}
        title={favouriteTitle}
        leadingIcon={favouriteIcon}
        onClick={handleFavouriteClick}
        className={classNames(!onlyResponses && classes.actionsButtonGap)}
      >
        {withCounters && status.favourites_count}
      </ToggleButton>
    </>
  );

  if (onlyResponses) {
    return <div className={classes.actions}>{responseButtons}</div>;
  }

  return (
    <div className={classes.actions}>
      {responseButtons}

      {isPublic && (
        <IconButton
          size='sm'
          variant='ghost'
          icon={ShareFatIcon}
          onClick={handleShareClick}
        >
          <FormattedMessage id='status.share' defaultMessage='Share' />
        </IconButton>
      )}

      <ToggleIconButton
        size='sm'
        variant='ghost'
        active={status.bookmarked}
        icon={bookmarkIcon}
        onClick={handleBookmarkClick}
      >
        {!status.bookmarked ? (
          <FormattedMessage id='status.save' defaultMessage='Save' />
        ) : (
          <FormattedMessage
            id='status.remove_from_saved'
            defaultMessage='Remove from Saved'
          />
        )}
      </ToggleIconButton>

      <RemoveQuoteHint
        className='status__action-bar__button-wrapper'
        canShowHint={shouldShowQuoteRemovalHint}
      >
        {(dismissQuoteHint) => (
          <StatusActionMenu
            dismissQuoteHint={dismissQuoteHint}
            status={status}
            withDismiss={withDismiss}
          />
        )}
      </RemoveQuoteHint>
    </div>
  );
};

const StatusReblogButton: React.FC<{
  statusId: string;
  children: React.ReactNode;
}> = ({ statusId, children }) => {
  const conditions = useAppSelector((state) =>
    selectStatusConditions(state, statusId),
  );
  const { isBoosted } = conditions;

  const boostState = boostItemState(conditions);
  const quoteState = quoteItemState(conditions);
  const intl = useIntl();

  const dispatch = useAppDispatch();
  const onReblog = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'reblog' }));
  }, [dispatch, statusId]);
  const onQuote = useCallback(() => {
    dispatch(statusInteraction({ statusId, intent: 'quote' }));
  }, [dispatch, statusId]);

  if (quickBoosting) {
    return (
      <ToggleButton
        size='sm'
        variant='ghost'
        active={isBoosted}
        leadingIcon={ArrowsClockwiseIcon}
        onClick={onReblog}
        disabled={boostState.disabled}
      >
        {children}
      </ToggleButton>
    );
  }

  return (
    <Menu>
      <MenuTrigger
        as={ToggleButton}
        size='sm'
        variant='ghost'
        active={isBoosted}
        leadingIcon={ArrowsClockwiseIcon}
      >
        {children}
      </MenuTrigger>

      <MenuList placement='bottom' maxWidth={180}>
        <MenuItem
          onClick={onReblog}
          icon={ArrowsClockwiseIcon}
          disabled={boostState.disabled}
          description={boostState.meta && intl.formatMessage(boostState.meta)}
        >
          {intl.formatMessage(boostState.title)}
        </MenuItem>
        <MenuItem
          onClick={onQuote}
          icon={QuotesFilledIcon}
          disabled={quoteState.disabled}
          description={quoteState.meta && intl.formatMessage(quoteState.meta)}
        >
          {intl.formatMessage(quoteState.title)}
        </MenuItem>
      </MenuList>
    </Menu>
  );
};

const QuotesFilledIcon = iconWeight(QuotesIcon, 'fill');

const StatusActionMenu: React.FC<{
  dismissQuoteHint: () => void;
  status: AccountStatusShape;
  withDismiss?: boolean;
}> = ({ status, dismissQuoteHint, withDismiss }) => {
  const { contextType } = useStatusContext();
  const dispatch = useAppDispatch();

  const menu = useStatusMenuActions({ status, contextType, withDismiss });

  const onOpen = useCallback(() => {
    // Replicates needsStatusRefresh of the Dropdown component.
    if (quickBoosting && !status.quote_approval) {
      dispatch(
        fetchStatus(status.id, { forceFetch: true, alsoFetchContext: false }),
      );
    }

    dismissQuoteHint();
  }, [dismissQuoteHint, dispatch, status.id, status.quote_approval]);

  return (
    <Menu onOpen={onOpen}>
      <MenuTrigger
        as={IconButton}
        size='sm'
        variant='ghost'
        icon={DotsThreeIcon}
      >
        <FormattedMessage id='status.more' defaultMessage='More' />
      </MenuTrigger>

      <MenuList placement='top-end'>
        <LegacyDropdownMenuItems items={menu} />
      </MenuList>
    </Menu>
  );
};
