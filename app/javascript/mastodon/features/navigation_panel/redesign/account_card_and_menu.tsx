import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  DotsThreeIcon,
  UserIcon,
  GearIcon,
  CirclesFourIcon,
  HeartIcon,
  BookmarkSimpleIcon,
  UsersThreeIcon,
  ProhibitIcon,
  SignOutIcon,
  BellSlashIcon,
  HandWavingIcon,
} from '@phosphor-icons/react';

import { openModal } from '@/mastodon/actions/modal';
import { Avatar } from '@/mastodon/components/avatar';
import { IconButton } from '@/mastodon/components/button/redesign';
import { DisplayName } from '@/mastodon/components/display_name';
import { useAccountHandle } from '@/mastodon/components/display_name/default';
import {
  LockupContent,
  LockupLink,
  LockupWrapper,
} from '@/mastodon/components/lockup';
import {
  Menu,
  MenuItem,
  MenuItemDivider,
  MenuItemGroup,
  MenuItemLink,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import { useAppDispatch } from '@/mastodon/store';

import classes from './account_card_and_menu.module.scss';

export const NavigationAccountCardAndMenu: React.FC = () => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  const handle = useAccountHandle(account);
  const accountBasePath = `/@${account?.acct}`;

  if (!accountId) {
    return null;
  }

  return (
    <LockupWrapper
      icon={<Avatar account={account} size={32} />}
      sideContent={
        <Menu type='navigation'>
          <MenuTrigger
            as={IconButton}
            icon={DotsThreeIcon}
            size='sm'
            variant='ghost'
          >
            <FormattedMessage
              id='tabs_bar.account_settings'
              defaultMessage='Account settings'
            />
          </MenuTrigger>
          <MenuList placement='top' offset={12} strategy='fixed' minWidth={220}>
            <AccountMenuItems />
          </MenuList>
        </Menu>
      }
      className={classes.root}
    >
      <LockupLink
        to={accountBasePath}
        subtitle={handle}
        className={classes.accountLink}
      >
        <DisplayName variant='simple' account={account} />
      </LockupLink>
    </LockupWrapper>
  );
};

export const AccountMenuItems: React.FC<{
  context?: 'default' | 'mobile';
}> = ({ context = 'default' }) => {
  const dispatch = useAppDispatch();
  const { accountId } = useIdentity();
  const account = useAccount(accountId);

  const confirmLogout = useCallback(() => {
    dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));
  }, [dispatch]);

  if (!accountId) {
    return null;
  }

  const accountBasePath = `/@${account?.acct}`;

  return (
    <>
      {context === 'mobile' && <ProfileMenuItem />}

      <MenuItemLink to={accountBasePath} exact icon={UserIcon}>
        <FormattedMessage
          id='account.view_profile'
          defaultMessage='View Profile'
        />
      </MenuItemLink>

      <MenuItemLink as='a' href='/settings/preferences' icon={GearIcon}>
        <FormattedMessage id='tabs_bar.settings' defaultMessage='Settings' />
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
          defaultMessage='Liked Posts'
        />
      </MenuItemLink>

      {context === 'mobile' && (
        <MenuItemLink to='/bookmarks' icon={BookmarkSimpleIcon}>
          <FormattedMessage
            id='navigation_bar.saved_posts'
            defaultMessage='Saved Posts'
          />
        </MenuItemLink>
      )}

      <MenuItemDivider />

      <MenuItemGroup
        label={
          <FormattedMessage
            id='navigation_bar.relationships'
            defaultMessage='Relationships'
          />
        }
      >
        <MenuItemLink to={`${accountBasePath}/followers`} icon={HandWavingIcon}>
          <FormattedMessage
            id='navigation_bar.followers'
            defaultMessage='Followers'
          />
        </MenuItemLink>

        <MenuItemLink to={`${accountBasePath}/following`} icon={UsersThreeIcon}>
          <FormattedMessage
            id='navigation_bar.following'
            defaultMessage='Following'
          />
        </MenuItemLink>

        <MenuItemLink to='/mutes' icon={BellSlashIcon}>
          <FormattedMessage id='navigation_bar.muted' defaultMessage='Muted' />
        </MenuItemLink>

        <MenuItemLink to='/blocks' icon={ProhibitIcon}>
          <FormattedMessage
            id='navigation_bar.blocked'
            defaultMessage='Blocked'
          />
        </MenuItemLink>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItem onClick={confirmLogout} icon={SignOutIcon}>
        <FormattedMessage
          id='navigation_bar.sign_out'
          defaultMessage='Sign Out'
        />
      </MenuItem>
    </>
  );
};

const ProfileMenuItem: React.FC = () => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  const handle = useAccountHandle(account);

  if (!accountId) {
    return null;
  }

  const accountBasePath = `/@${account?.acct}`;

  return (
    <MenuItemLink to={accountBasePath} exact>
      <LockupWrapper
        icon={<Avatar account={account} size={40} />}
        className={classes.profileMenuItem}
      >
        <LockupContent subtitle={handle}>
          <DisplayName variant='simple' account={account} />
        </LockupContent>
      </LockupWrapper>
    </MenuItemLink>
  );
};
