import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  DotsThreeIcon,
  UserIcon,
  GearIcon,
  CirclesFourIcon,
  HeartIcon,
  UsersThreeIcon,
  ProhibitIcon,
  GavelIcon,
  ShieldStarIcon,
  SignOutIcon,
} from '@phosphor-icons/react';

import { openModal } from '@/mastodon/actions/modal';
import { Account } from '@/mastodon/components/account';
import { IconButton } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuItem,
  MenuItemDivider,
  MenuItemLink,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import {
  canManageReports,
  canViewAdminDashboard,
} from '@/mastodon/permissions';
import { useAppDispatch } from '@/mastodon/store';

import classes from './account_card_and_menu.module.scss';

export const NavigationAccountCardAndMenu: React.FC = () => {
  const dispatch = useAppDispatch();
  const { accountId, permissions } = useIdentity();
  const account = useAccount(accountId);

  const confirmLogout = useCallback(() => {
    dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));
  }, [dispatch]);

  if (!accountId) {
    return null;
  }

  const isManager = canManageReports(permissions);
  const isAdmin = canViewAdminDashboard(permissions);

  const accountBasePath = `/@${account?.acct}`;

  return (
    <div className={classes.root}>
      <Account
        id={accountId}
        minimal
        withBorder={false}
        withMenu={false}
        size={32}
      />
      <Menu type='navigation'>
        <MenuTrigger
          as={IconButton}
          icon={DotsThreeIcon}
          variant='ghost'
          size='sm'
        >
          <FormattedMessage id='tabs_bar.more' defaultMessage='More' />
        </MenuTrigger>
        <MenuList placement='top' offset={8}>
          <MenuItemLink to='/profile/edit' icon={UserIcon}>
            <FormattedMessage
              id='account.edit_profile'
              defaultMessage='Edit profile'
            />
          </MenuItemLink>
          <MenuItemLink as='a' href='/settings/preferences' icon={GearIcon}>
            <FormattedMessage
              id='tabs_bar.settings'
              defaultMessage='Settings'
            />
          </MenuItemLink>

          <MenuItemDivider />

          <MenuItemLink
            to={`${accountBasePath}/collections`}
            icon={CirclesFourIcon}
          >
            <FormattedMessage
              id='navigation_bar.collections'
              defaultMessage='Collections'
            />
          </MenuItemLink>
          <MenuItemLink to='/favourites' icon={HeartIcon}>
            <FormattedMessage
              id='navigation_bar.liked_posts'
              defaultMessage='Liked posts'
            />
          </MenuItemLink>

          <MenuItemDivider />

          <MenuItemLink as='a' href='/relationships' icon={UsersThreeIcon}>
            <FormattedMessage
              id='navigation_bar.followers_and_following'
              defaultMessage='Followers & Following'
            />
          </MenuItemLink>

          <MenuItemLink to='/blocks' icon={ProhibitIcon}>
            <FormattedMessage
              id='navigation_bar.blocked_accounts'
              defaultMessage='Blocked accounts'
            />
          </MenuItemLink>

          {(isManager || isAdmin) && (
            <>
              <MenuItemDivider />

              {isAdmin && (
                <MenuItemLink as='a' href='/admin/dashboard' icon={GavelIcon}>
                  <FormattedMessage
                    id='navigation_bar.administration'
                    defaultMessage='Administration'
                  />
                </MenuItemLink>
              )}

              {isManager && (
                <MenuItemLink
                  as='a'
                  href='/admin/reports'
                  icon={ShieldStarIcon}
                >
                  <FormattedMessage
                    id='navigation_bar.moderation'
                    defaultMessage='Moderation'
                  />
                </MenuItemLink>
              )}
            </>
          )}

          <MenuItemDivider />

          <MenuItem onClick={confirmLogout} icon={SignOutIcon}>
            <FormattedMessage
              id='navigation_bar.sign_out'
              defaultMessage='Sign out'
            />
          </MenuItem>
        </MenuList>
      </Menu>
    </div>
  );
};
