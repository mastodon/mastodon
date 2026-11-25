import { useCallback, useEffect, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import { useLocation } from 'react-router';

import type { Placement } from '@floating-ui/react-dom';
import {
  BellIcon,
  ChatCircleDotsIcon,
  HouseIcon,
  MagnifyingGlassIcon,
} from '@phosphor-icons/react';

import { Avatar } from '@/mastodon/components/avatar';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';
import { Search } from '@/mastodon/components/search';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import {
  closeInlineSearch,
  openInlineSearch,
} from '@/mastodon/reducers/slices/navigation';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { handleSearchLinkClick } from '.';
import { AccountMenuItems } from './account_menu_items';
import { useNotificationsCount } from './hooks';
import classes from './mini_nav.module.scss';
import type { MiniNavigationLinkProps } from './navigation_link';
import { MiniNavigationLink } from './navigation_link';

/**
 * The small link bar at the top of the main navigation
 */
export const MiniNav: React.FC = () => {
  const dispatch = useAppDispatch();
  const shouldHandleFocusRef = useRef(false);
  const searchFieldRef = useRef<HTMLInputElement>(null);
  const searchButtonRef = useRef<HTMLButtonElement>(null);
  const isSearchOpen = useAppSelector(
    (state) => state.navigation.isInlineSearchOpen,
  );

  const openSearch = useCallback(() => {
    dispatch(openInlineSearch());
    shouldHandleFocusRef.current = true;
    handleSearchLinkClick();
  }, [dispatch]);

  const closeSearch = useCallback(
    (shouldHandleFocus: boolean) => {
      dispatch(closeInlineSearch());
      shouldHandleFocusRef.current = shouldHandleFocus;
    },
    [dispatch],
  );

  useEffect(() => {
    if (shouldHandleFocusRef.current) {
      if (isSearchOpen) {
        searchFieldRef.current?.focus();
      } else {
        searchButtonRef.current?.focus();
      }
    }
  }, [isSearchOpen]);

  // Close after navigation change
  const { pathname, search } = useLocation();
  const pathWithSearch = `${pathname}${search}`;
  useEffect(() => {
    dispatch(closeInlineSearch());
  }, [pathWithSearch, dispatch]);

  return (
    <div className={classes.root}>
      {isSearchOpen ? (
        <Search
          singleColumn
          context='sidebar'
          ref={searchFieldRef}
          onClose={closeSearch}
        />
      ) : (
        <ul className={classes.list}>
          <li>
            <MiniHomeLink />
          </li>
          <li>
            <MiniNavigationLink
              as='button'
              icon={MagnifyingGlassIcon}
              onClick={openSearch}
              ref={searchButtonRef}
            >
              <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
            </MiniNavigationLink>
          </li>
          <li>
            <MiniMessagesLink />
          </li>
          <li>
            <MiniNotificationsLink />
          </li>
          <li>
            <MiniAccountLink />
          </li>
        </ul>
      )}
    </div>
  );
};

export const MiniHomeLink: React.FC<
  Pick<MiniNavigationLinkProps, 'tooltipPlacement'>
> = ({ tooltipPlacement }) => (
  <MiniNavigationLink
    to='/home'
    icon={HouseIcon}
    tooltipPlacement={tooltipPlacement}
  >
    <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
  </MiniNavigationLink>
);

export const MiniMessagesLink: React.FC<
  Pick<MiniNavigationLinkProps, 'tooltipPlacement'>
> = ({ tooltipPlacement }) => (
  <MiniNavigationLink
    to='/conversations'
    icon={ChatCircleDotsIcon}
    tooltipPlacement={tooltipPlacement}
  >
    <FormattedMessage
      id='tabs_bar.messages'
      defaultMessage='Messages'
      description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
    />
  </MiniNavigationLink>
);

export const MiniNotificationsLink: React.FC<
  Pick<MiniNavigationLinkProps, 'tooltipPlacement' | 'badgeType'>
> = (props) => {
  const notificationsCount = useNotificationsCount();
  return (
    <MiniNavigationLink
      to='/notifications'
      icon={BellIcon}
      badgeCount={notificationsCount}
      {...props}
    >
      <FormattedMessage
        id='tabs_bar.notifications'
        defaultMessage='Notifications'
      />
    </MiniNavigationLink>
  );
};

export const MiniAccountLink: React.FC<
  Pick<MiniNavigationLinkProps, 'tooltipPlacement'> & {
    menuPlacement?: Placement;
  }
> = ({ tooltipPlacement, menuPlacement = 'top-end' }) => {
  return (
    <Menu type='navigation'>
      <MenuTrigger
        as={AccountButton}
        withMenuIndicator
        tooltipPlacement={tooltipPlacement}
      >
        <FormattedMessage id='tabs_bar.account' defaultMessage='Account' />
      </MenuTrigger>
      <MenuList placement={menuPlacement} offset={8} maxWidth={240}>
        <AccountMenuItems />
      </MenuList>
    </Menu>
  );
};

interface AccountButton
  extends
    Pick<MiniNavigationLinkProps, 'tooltipPlacement' | 'withMenuIndicator'>,
    React.ComponentPropsWithRef<'button'> {}

export const AccountButton: React.FC<AccountButton> = ({
  children,
  ...otherProps
}) => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  return (
    <MiniNavigationLink
      as='button'
      icon={{
        customIcon: <Avatar size={20} account={account} />,
      }}
      {...otherProps}
    >
      {children}
    </MiniNavigationLink>
  );
};
