import { useCallback, useMemo } from 'react';
import type { FC, KeyboardEvent, MouseEvent, MouseEventHandler } from 'react';

import { useIntl } from 'react-intl';

import classNames from 'classnames';

import { quoteComposeById } from '@/mastodon/actions/compose_typed';
import { toggleReblog } from '@/mastodon/actions/interactions';
import { openModal } from '@/mastodon/actions/modal';
import { fetchStatus } from '@/mastodon/actions/statuses';
import { quickBoosting } from '@/mastodon/initial_state';
import type { ActionMenuItem } from '@/mastodon/models/dropdown_menu';
import type { Status } from '@/mastodon/models/status';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import type { SomeRequired } from '@/mastodon/utils/types';

import type { RenderItemFn } from '../dropdown_menu';
import { Dropdown, DropdownMenuItemContent } from '../dropdown_menu';
import { IconButton } from '../icon_button';

import {
  boostItemState,
  messages,
  quoteItemState,
  selectStatusState,
} from './boost_button_utils';

const StandaloneBoostButton: FC<ReblogButtonProps> = ({ status, counters }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const statusState = useAppSelector((state) =>
    selectStatusState(state, status),
  );
  const { title, meta, iconComponent, disabled } = useMemo(
    () => boostItemState(statusState),
    [statusState],
  );

  const handleClick: MouseEventHandler = useCallback(
    (event) => {
      if (statusState.isLoggedIn) {
        dispatch(toggleReblog(status.get('id') as string, event.shiftKey));
      } else {
        dispatch(
          openModal({
            modalType: 'INTERACTION',
            modalProps: {
              accountId: status.getIn(['account', 'id']),
              url: status.get('uri'),
            },
          }),
        );
      }
    },
    [dispatch, status, statusState.isLoggedIn],
  );

  return (
    <IconButton
      disabled={disabled}
      active={!!status.get('reblogged')}
      title={intl.formatMessage(meta ?? title)}
      icon='retweet'
      iconComponent={iconComponent}
      className='status__action-bar__button'
      onClick={!disabled ? handleClick : undefined}
      counter={
        counters
          ? (status.get('reblogs_count') as number) +
            (status.get('quotes_count') as number)
          : undefined
      }
    />
  );
};

const renderMenuItem: RenderItemFn<ActionMenuItem> = (item, index, onClick) => (
  <ReblogMenuItem
    index={index}
    item={item}
    onClick={onClick}
    key={`${item.text}-${index}`}
  />
);

interface ReblogButtonProps {
  status: Status;
  counters?: boolean;
}

type ActionMenuItemWithIcon = SomeRequired<ActionMenuItem, 'icon'>;

const BoostOrQuoteMenu: FC<ReblogButtonProps> = ({ status, counters }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const statusState = useAppSelector((state) =>
    selectStatusState(state, status),
  );
  const {
    isLoggedIn,
    isReblogged,
    isReblogAllowed,
    isQuoteAutomaticallyAccepted,
    isQuoteManuallyAccepted,
  } = statusState;

  const isMenuDisabled =
    !isQuoteAutomaticallyAccepted &&
    !isQuoteManuallyAccepted &&
    !isReblogAllowed;

  const statusId = status.get('id') as string;
  const wasBoosted = !!status.get('reblogged');
  const quoteApproval = status.get('quote_approval');

  const showLoginPrompt = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'INTERACTION',
        modalProps: {
          accountId: status.getIn(['account', 'id']),
          url: status.get('uri'),
        },
      }),
    );
  }, [dispatch, status]);

  const items = useMemo(() => {
    const boostItem = boostItemState(statusState);
    const quoteItem = quoteItemState(statusState);
    return [
      {
        text: intl.formatMessage(boostItem.title),
        description: boostItem.meta
          ? intl.formatMessage(boostItem.meta)
          : undefined,
        icon: boostItem.iconComponent,
        highlighted: wasBoosted,
        disabled: boostItem.disabled,
        action: (event) => {
          dispatch(toggleReblog(statusId, event.shiftKey));
        },
      },
      {
        text: intl.formatMessage(quoteItem.title),
        description: quoteItem.meta
          ? intl.formatMessage(quoteItem.meta)
          : undefined,
        icon: quoteItem.iconComponent,
        disabled: quoteItem.disabled,
        action: () => {
          dispatch(quoteComposeById(statusId));
        },
      },
    ] satisfies [ActionMenuItemWithIcon, ActionMenuItemWithIcon];
  }, [dispatch, intl, statusId, statusState, wasBoosted]);

  const boostIcon = items[0].icon;

  const handleDropdownOpen = useCallback(
    (event: MouseEvent | KeyboardEvent) => {
      if (!isLoggedIn) {
        showLoginPrompt();
        return false;
      }

      if (event.shiftKey) {
        dispatch(toggleReblog(status.get('id'), true));
        return false;
      }

      if (quoteApproval === null) {
        dispatch(
          fetchStatus(statusId, { forceFetch: true, alsoFetchContext: false }),
        );
      }

      return true;
    },
    [dispatch, isLoggedIn, showLoginPrompt, status, quoteApproval, statusId],
  );

  return (
    <Dropdown
      placement='bottom-start'
      offset={[-19, 5]} // This aligns button icon with menu icons
      items={items}
      renderItem={renderMenuItem}
      onOpen={handleDropdownOpen}
      disabled={isMenuDisabled}
    >
      <IconButton
        title={intl.formatMessage(
          isMenuDisabled ? messages.all_disabled : messages.reblog_or_quote,
        )}
        icon='retweet'
        className='status__action-bar__button'
        iconComponent={boostIcon}
        counter={
          counters
            ? (status.get('reblogs_count') as number) +
              (status.get('quotes_count') as number)
            : undefined
        }
        active={isReblogged}
      />
    </Dropdown>
  );
};

interface ReblogMenuItemProps {
  item: ActionMenuItem;
  index: number;
  onClick: React.MouseEventHandler;
}

const ReblogMenuItem: FC<ReblogMenuItemProps> = ({ index, item, onClick }) => {
  const { text, highlighted, disabled } = item;

  return (
    <li
      className={classNames('dropdown-menu__item reblog-menu-item', {
        'dropdown-menu__item--highlighted': highlighted,
      })}
      key={`${text}-${index}`}
    >
      <button
        onClick={onClick}
        aria-disabled={disabled}
        data-index={index}
        type='button'
      >
        <DropdownMenuItemContent item={item} />
      </button>
    </li>
  );
};

// Switch between the standalone boost button or the
// "Boost or quote" menu based on the quickBoosting preference
export const BoostButton = quickBoosting
  ? StandaloneBoostButton
  : BoostOrQuoteMenu;
