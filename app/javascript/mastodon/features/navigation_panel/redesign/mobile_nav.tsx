import { FormattedMessage } from 'react-intl';

import {
  BellIcon,
  ChatCircleIcon,
  HouseIcon,
  MagnifyingGlassIcon,
} from '@phosphor-icons/react';

import { Avatar } from '@/mastodon/components/avatar';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { ComposeRedesignButton } from '@/mastodon/features/compose/redesign/trigger';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useIdentity } from '@/mastodon/identity_context';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppSelector } from '@/mastodon/store';

import classes from './mobile_nav.module.scss';
import { MobileNavLink } from './navigation_link';

export const RedesignMobileNavigation: React.FC = () => {
  const { accountId } = useIdentity();
  const account = useAccount(accountId);
  const notificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );
  return (
    <nav className={classes.root}>
      <ul className={classes.list}>
        <MobileNavLink to='/home' iconComponent={HouseIcon}>
          <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
        </MobileNavLink>
        <MobileNavLink
          to={{
            pathname: '/explore',
            state: { focusTarget: FOCUS_TARGET.SEARCH },
          }}
          iconComponent={MagnifyingGlassIcon}
        >
          <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
        </MobileNavLink>
        <MobileNavLink to='/conversations' iconComponent={ChatCircleIcon}>
          <FormattedMessage
            id='tabs_bar.messages'
            defaultMessage='Messages'
            description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
          />
        </MobileNavLink>
        <MobileNavLink
          to='/notifications'
          iconComponent={BellIcon}
          withDot={notificationsCount > 0}
        >
          <FormattedMessage
            id='tabs_bar.notifications'
            defaultMessage='Notifications'
          />
        </MobileNavLink>
        <MobileNavLink
          to={`/@${account?.acct}`}
          customIcon={
            <Avatar size={24} account={account} className={classes.avatar} />
          }
        >
          <FormattedMessage id='tabs_bar.profile' defaultMessage='Profile' />
        </MobileNavLink>
      </ul>
      <ComposeRedesignButton inline />
    </nav>
  );
};
