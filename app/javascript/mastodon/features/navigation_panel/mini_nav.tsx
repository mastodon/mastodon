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
import { MiniNavLink, MiniNavProfileButton } from './navigation_link';

/**
 * The small link bar at the top of the main navigation
 */
export const MiniNav: React.FC = () => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  const notificationsCount = useNotificationsCount();
  return (
    <ul className={classes.root}>
      <MiniNavLink to='/home' iconComponent={HouseIcon}>
        <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
      </MiniNavLink>
      <MiniNavLink
        to={{
          pathname: '/search',
          state: { focusTarget: FOCUS_TARGET.SEARCH },
        }}
        iconComponent={MagnifyingGlassIcon}
        onClick={handleSearchLinkClick}
      >
        <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
      </MiniNavLink>
      <MiniNavLink to='/conversations' iconComponent={ChatCircleDotsIcon}>
        <FormattedMessage
          id='tabs_bar.messages'
          defaultMessage='Messages'
          description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
        />
      </MiniNavLink>
      <MiniNavLink
        to='/notifications'
        iconComponent={BellIcon}
        withDot={notificationsCount > 0}
      >
        <FormattedMessage
          id='tabs_bar.notifications'
          defaultMessage='Notifications'
        />
      </MiniNavLink>
      <Menu>
        <MenuTrigger
          as={MiniNavProfileButton}
          avatar={
            <Avatar size={20} account={account} className={classes.avatar} />
          }
        >
          <FormattedMessage id='tabs_bar.account' defaultMessage='Account' />
        </MenuTrigger>
        <MenuList placement='top-end' offset={8} minWidth={240}>
          <AccountMenuItems />
        </MenuList>
      </Menu>
    </ul>
  );
};
