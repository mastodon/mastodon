import { useCallback, useEffect, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  BellIcon,
  ChatCircleDotsIcon,
  HouseIcon,
  MagnifyingGlassIcon,
} from '@phosphor-icons/react';

import { toggleInlineSearch } from '@/mastodon/actions/navigation';
import { Avatar } from '@/mastodon/components/avatar';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';
import { Search } from '@/mastodon/components/search';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { handleSearchLinkClick, useNotificationsCount } from '.';
import { AccountMenuItems } from './account_menu_items';
import classes from './mini_nav.module.scss';
import { MiniNavigationLink } from './navigation_link';

/**
 * The small link bar at the top of the main navigation
 */
export const MiniNav: React.FC = () => {
  const dispatch = useAppDispatch();
  const shouldHandleFocusRef = useRef(false);
  const searchFieldRef = useRef<HTMLInputElement>(null);
  const searchButtonRef = useRef<HTMLButtonElement>(null);
  const isSearchOpen = useAppSelector((state) => state.navigation.searchOpen);

  const toggleSearch = useCallback(() => {
    dispatch(toggleInlineSearch());
    shouldHandleFocusRef.current = true;

    if (!isSearchOpen) {
      handleSearchLinkClick();
    }
  }, [dispatch, isSearchOpen]);

  useEffect(() => {
    if (shouldHandleFocusRef.current) {
      if (isSearchOpen) {
        searchFieldRef.current?.focus();
      } else {
        searchButtonRef.current?.focus();
      }
    }
  }, [isSearchOpen]);

  const notificationsCount = useNotificationsCount();

  return (
    <div className={classes.root}>
      {isSearchOpen ? (
        <Search
          singleColumn
          context='sidebar'
          ref={searchFieldRef}
          onClose={toggleSearch}
        />
      ) : (
        <ul className={classes.list}>
          <MiniNavigationLink to='/home' icon={HouseIcon}>
            <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
          </MiniNavigationLink>
          <MiniNavigationLink
            as='button'
            icon={MagnifyingGlassIcon}
            onClick={toggleSearch}
            ref={searchButtonRef}
          >
            <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
          </MiniNavigationLink>
          <MiniNavigationLink to='/conversations' icon={ChatCircleDotsIcon}>
            <FormattedMessage
              id='tabs_bar.messages'
              defaultMessage='Messages'
              description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
            />
          </MiniNavigationLink>
          <MiniNavigationLink
            to='/notifications'
            icon={BellIcon}
            badgeCount={notificationsCount}
          >
            <FormattedMessage
              id='tabs_bar.notifications'
              defaultMessage='Notifications'
            />
          </MiniNavigationLink>
          <Menu>
            <MenuTrigger as={AccountButton} withMenuIndicator>
              <FormattedMessage
                id='tabs_bar.account'
                defaultMessage='Account'
              />
            </MenuTrigger>
            <MenuList placement='top-end' offset={8} minWidth={240}>
              <AccountMenuItems />
            </MenuList>
          </Menu>
        </ul>
      )}
    </div>
  );
};

interface AccountButton extends React.ComponentPropsWithRef<'button'> {
  withMenuIndicator?: boolean;
}

export const AccountButton: React.FC<AccountButton> = ({
  children,
  withMenuIndicator,
  ...otherProps
}) => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  return (
    <MiniNavigationLink
      as='button'
      withMenuIndicator={withMenuIndicator}
      icon={{
        customIcon: (
          <Avatar size={20} account={account} className={classes.avatar} />
        ),
      }}
      {...otherProps}
    >
      {children}
    </MiniNavigationLink>
  );
};
