import { FormattedMessage } from 'react-intl';

import {
  BellIcon,
  ChatCircleDotsIcon,
  HouseIcon,
  MagnifyingGlassIcon,
} from '@phosphor-icons/react';

import { Avatar } from '@/mastodon/components/avatar';
import { Menu, MenuList, MenuTrigger } from '@/mastodon/components/menu';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';

import { handleSearchLinkClick, useNotificationsCount } from '.';
import { AccountMenuItems } from './account_menu_items';
import classes from './mini_nav.module.scss';
import { MiniNavigationLink } from './navigation_link';

/**
 * The small link bar at the top of the main navigation
 */
export const MiniNav: React.FC = () => {
  const notificationsCount = useNotificationsCount();
  return (
    <ul className={classes.root}>
      <MiniNavigationLink to='/home' icon={HouseIcon}>
        <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
      </MiniNavigationLink>
      <MiniNavigationLink
        to={{
          pathname: '/search',
          state: { focusTarget: FOCUS_TARGET.SEARCH },
        }}
        icon={MagnifyingGlassIcon}
        onClick={handleSearchLinkClick}
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
        withDot={notificationsCount > 0}
      >
        <FormattedMessage
          id='tabs_bar.notifications'
          defaultMessage='Notifications'
        />
      </MiniNavigationLink>
      <Menu>
        <MenuTrigger as={AccountButton}>
          <FormattedMessage id='tabs_bar.account' defaultMessage='Account' />
        </MenuTrigger>
        <MenuList placement='top-end' offset={8} minWidth={240}>
          <AccountMenuItems />
        </MenuList>
      </Menu>
    </ul>
  );
};

export const AccountButton: React.FC<React.ComponentPropsWithRef<'button'>> = ({
  children,
  ...otherProps
}) => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  return (
    <MiniNavigationLink
      as='button'
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
