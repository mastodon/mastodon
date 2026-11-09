import { useCallback, useEffect, useId, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { DotsThreeIcon, ShareFatIcon } from '@phosphor-icons/react';

import { statusInteraction } from '@/mastodon/actions/interactions';
import { fetchStatus } from '@/mastodon/actions/statuses';
import { useCurrentAccountId } from '@/mastodon/hooks/useAccountId';
import { useDismissible } from '@/mastodon/hooks/useDismissible';
import { useAccountStatus } from '@/mastodon/hooks/useStatus';
import { quickBoosting } from '@/mastodon/initial_state';
import type { AccountStatusShape, StatusShape } from '@/mastodon/models/status';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { AnimatedNumber } from '../animated_number';
import { Button, IconButton, ToggleButton, ToggleIconButton } from '../button';
import { Icon } from '../icon';
import {
  Menu,
  MenuItem,
  MenuList,
  MenuTrigger,
  LegacyDropdownMenuItems,
} from '../menu';
import { Popover } from '../popover';

import {
  useStatusContext,
  useStatusIcons,
  useStatusMenuActions,
} from './hooks';
import {
  StatusLikeBurstActiveIcon,
  StatusLikeBurstIcon,
} from './like_burst_icon';
import classes from './styles.module.scss';

interface StatusActionBarProps {
  statusId: string;
  reblogId: string | undefined;
  withDismiss?: boolean;
  withCounters?: boolean;
}

export const StatusActionBar: React.FC<StatusActionBarProps> = ({
  statusId,
  reblogId,
  withDismiss,
  withCounters,
}) => {
  const status = useAccountStatus(statusId);
  const reblogStatus = useAccountStatus(reblogId);
  const { contextType } = useStatusContext();
  const statusUrl = status?.url ?? status?.uri;

  // Actions
  const dispatch = useAppDispatch();
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

  const { reply, like, bookmark } = useStatusIcons(statusId);

  const currentAccountId = useCurrentAccountId();

  const [likeBurst, setLikeBurst] = useState(false);

  const handleLikeClick = useCallback(
    (event: React.MouseEvent<HTMLButtonElement>) => {
      if (currentAccountId && !like.active) {
        setLikeBurst(true);
      }

      like.action(event);
    },
    [currentAccountId, like],
  );

  const handleLikeAnimationEnd = useCallback(
    (event: React.AnimationEvent<HTMLButtonElement>) => {
      if (event.animationName.endsWith('heart-pop')) {
        setLikeBurst(false);
      }
    },
    [],
  );

  if (!status) {
    return null;
  }

  const isPublic =
    status.visibility === 'public' || status.visibility === 'unlisted';

  return (
    <div className={classes.actions}>
      <Button
        size='sm'
        clipPadding
        variant='ghost'
        leadingIcon={reply.icon}
        onClick={reply.action}
        tooltip={{ type: 'label', text: reply.title }}
      >
        {withCounters && <AnimatedNumber value={reply.counter ?? 0} />}
      </Button>

      <StatusReblogButton statusId={statusId}>
        {withCounters && <AnimatedNumber value={status.reblogs_count} />}
      </StatusReblogButton>

      <ToggleButton
        size='sm'
        variant='ghost'
        active={like.active}
        tooltip={{ type: 'label', text: like.title }}
        leadingIcon={
          like.active ? StatusLikeBurstActiveIcon : StatusLikeBurstIcon
        }
        onClick={handleLikeClick}
        data-like-burst={likeBurst || undefined}
        onAnimationEnd={handleLikeAnimationEnd}
        className={classes.actionsButtonGap}
      >
        {withCounters && <AnimatedNumber value={like.counter ?? 0} />}
      </ToggleButton>

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
        active={bookmark.active}
        icon={bookmark.icon}
        onClick={bookmark.action}
      >
        {bookmark.title}
      </ToggleIconButton>

      <StatusActionMenu
        status={status}
        reblogStatus={reblogStatus}
        withDismiss={withDismiss}
      />
    </div>
  );
};

export const StatusReblogButton: React.FC<{
  statusId: string;
  children: React.ReactNode;
}> = ({ statusId, children }) => {
  const { boost, quote } = useStatusIcons(statusId);

  const isBoosted = !!boost.active;
  const [wasBoosted, setWasBoosted] = useState(isBoosted);
  const [boostSpin, setBoostSpin] = useState(false);

  if (isBoosted !== wasBoosted) {
    setWasBoosted(isBoosted);
    setBoostSpin(isBoosted);
  }

  const handleBoostAnimationEnd = useCallback(() => {
    setBoostSpin(false);
  }, []);

  const handleShiftClick = useCallback(
    (e: React.MouseEvent) => {
      if (e.shiftKey) {
        e.preventDefault();
        boost.action(e);
      }
    },
    [boost],
  );

  const preventMenuOpenOnShiftClick = useCallback((e?: React.MouseEvent) => {
    return !e?.shiftKey;
  }, []);

  if (quickBoosting) {
    return (
      <ToggleButton
        size='sm'
        variant='ghost'
        active={boost.active}
        tooltip={{
          type: 'label',
          text: boost.title,
        }}
        leadingIcon={boost.icon}
        disabled={boost.disabled}
        onClick={boost.action}
        className={boostSpin ? classes.boostSpin : undefined}
        onAnimationEnd={handleBoostAnimationEnd}
      >
        {children}
      </ToggleButton>
    );
  }

  return (
    <Menu onOpen={preventMenuOpenOnShiftClick}>
      <MenuTrigger
        as={ToggleButton}
        size='sm'
        variant='ghost'
        active={boost.active}
        disabled={boost.disabled && quote.disabled}
        tooltip={{
          type: 'label',
          text: (
            <FormattedMessage
              id='status.reblog_or_quote'
              defaultMessage='Boost or quote'
            />
          ),
        }}
        onClick={handleShiftClick}
        leadingIcon={boost.icon}
        className={boostSpin ? classes.boostSpin : undefined}
        onAnimationEnd={handleBoostAnimationEnd}
      >
        {children}
      </MenuTrigger>

      <MenuList placement='bottom' maxWidth={180}>
        <MenuItem
          onClick={boost.action}
          icon={boost.icon}
          disabled={boost.disabled}
          description={boost.meta}
        >
          {boost.title}
        </MenuItem>
        <MenuItem
          onClick={quote.action}
          icon={quote.icon}
          disabled={quote.disabled}
          description={quote.meta}
        >
          {quote.title}
        </MenuItem>
      </MenuList>
    </Menu>
  );
};

const StatusActionMenu: React.FC<{
  status: AccountStatusShape;
  reblogStatus: AccountStatusShape | null;
  withDismiss?: boolean;
}> = ({ status, reblogStatus, withDismiss }) => {
  const { contextType } = useStatusContext();
  const dispatch = useAppDispatch();

  const menu = useStatusMenuActions({
    status,
    reblogStatus,
    contextType,
    withDismiss,
  });

  const { showHint, dismiss } = useQuoteHint({ status });
  const [buttonEle, setButtonEle] = useState<HTMLButtonElement | null>(null);

  const onOpen = useCallback(() => {
    // Replicates needsStatusRefresh of the Dropdown component.
    if (quickBoosting && !status.quote_approval) {
      dispatch(
        fetchStatus(status.id, { forceFetch: true, alsoFetchContext: false }),
      );
    }

    dismiss();
  }, [dismiss, dispatch, status.id, status.quote_approval]);

  return (
    <Menu onOpen={onOpen}>
      <MenuTrigger
        as={IconButton}
        size='sm'
        variant='ghost'
        icon={DotsThreeIcon}
        ref={setButtonEle}
      >
        <FormattedMessage id='status.more' defaultMessage='More' />
      </MenuTrigger>

      <MenuList placement='top-end'>
        <LegacyDropdownMenuItems items={menu} />
      </MenuList>

      {showHint && (
        <QuoteHintTooltip anchorElement={buttonEle} dismiss={dismiss} />
      )}
    </Menu>
  );
};

const QUOTE_HINT_BANNER_ID = 'notifications/remove_quote_hint';

/**
 * We don't want to show this hint in the UI more than once,
 * so the first time it renders, we store a unique component ID
 * here to prevent any other hints from being displayed after it.
 */
let firstHintId: string | null = null;

function useQuoteHint({ status }: { status?: Pick<StatusShape, 'quote'> }) {
  const { contextType } = useStatusContext();
  const quotedAccountId = useAppSelector(
    (state) =>
      state.statuses.getIn([status?.quote?.quoted_status, 'account']) ?? null,
  );
  const currentAccountId = useCurrentAccountId();
  const isQuotingMe = quotedAccountId === currentAccountId;
  const shouldShowQuoteRemovalHint =
    isQuotingMe && contextType === 'notifications';

  const { wasDismissed, dismiss } = useDismissible(QUOTE_HINT_BANNER_ID);

  const shouldShowHint = !wasDismissed && shouldShowQuoteRemovalHint;

  const uniqueId = useId();
  const [isOnlyHint, setIsOnlyHint] = useState(false);
  useEffect(() => {
    if (!shouldShowHint) {
      return () => null;
    }

    if (!firstHintId) {
      firstHintId = uniqueId;
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setIsOnlyHint(true);
    }

    return () => {
      if (firstHintId === uniqueId) {
        firstHintId = null;
        setIsOnlyHint(false);
      }
    };
  }, [shouldShowHint, uniqueId]);

  return {
    showHint: isOnlyHint && shouldShowHint,
    dismiss,
  };
}

const QuoteHintTooltip: React.FC<{
  anchorElement: HTMLElement | null;
  dismiss: () => void;
}> = ({ anchorElement, dismiss }) => {
  const intl = useIntl();
  return (
    <Popover
      isOpen
      offset={{ mainAxis: 10, crossAxis: 12 }}
      placement='bottom-end'
      reference={anchorElement}
      container={null}
      onClose={dismiss}
    >
      {({ props, placement }) => (
        <div
          {...props}
          className={classNames('info-tooltip dropdown-animation', placement)}
        >
          <FormattedMessage
            id='remove_quote_hint.title'
            defaultMessage='Want to remove your quoted post?'
            tagName='h4'
          />

          <FormattedMessage
            id='remove_quote_hint.message'
            defaultMessage='You can do so from the {icon} options menu.'
            values={{
              icon: (
                <Icon
                  icon={DotsThreeIcon}
                  aria-label={intl.formatMessage({
                    id: 'status.more',
                    defaultMessage: 'More',
                  })}
                  className={classes.inlineIcon}
                />
              ),
            }}
            tagName='p'
          />

          <Button
            variant='ghost'
            color='accent'
            size='sm'
            clipPadding
            onClick={dismiss}
            className={classes.button}
          >
            <FormattedMessage
              id='remove_quote_hint.button_label'
              defaultMessage='Got it'
            />
          </Button>
        </div>
      )}
    </Popover>
  );
};
