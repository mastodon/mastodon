import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  PenNibIcon,
  HouseIcon,
  MagnifyingGlassIcon,
  BellIcon,
  ChatCircleIcon,
  BookmarkSimpleIcon,
} from '@phosphor-icons/react';

import FediIcon from '@/images/icons/icon_fediverse.svg?react';
import { useIdentity } from '@/mastodon/identity_context';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { NavigationAccountCardAndMenu } from './account_card_and_menu';
import { NavigationFooterLinks } from './footer_links';
import { NavigationHeader } from './header';
import { NavigationLink } from './navigation_link';
import classes from './styles.module.scss';

const messages = defineMessages({
  main: {
    id: 'navigation_bar.main',
    defaultMessage: 'Main',
    description:
      'Label for the main navigation; should not contain the word "navigation".',
  },
});

export const RedesignNavigationPanel: React.FC<{ siteName?: string }> = ({
  siteName,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const notificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );

  const openComposer = useCallback(() => {
    dispatch(openNewComposer({ type: 'post' }));
  }, [dispatch]);

  return (
    <nav
      className={classes.root}
      aria-label={intl.formatMessage(messages.main)}
    >
      <NavigationHeader siteName={siteName} />
      {signedIn && (
        <>
          <ul className={classes.list}>
            <NavigationLink
              withSpaceAfter
              as='button'
              onClick={openComposer}
              iconComponent={PenNibIcon}
            >
              <FormattedMessage
                id='tabs_bar.publish'
                defaultMessage='New Post'
              />
            </NavigationLink>
            <NavigationLink to='/home' iconComponent={HouseIcon}>
              <FormattedMessage id='tabs_bar.home' defaultMessage='Home' />
            </NavigationLink>
            <NavigationLink to='/explore' iconComponent={MagnifyingGlassIcon}>
              <FormattedMessage
                id='tabs_bar.explore'
                defaultMessage='Explore'
              />
            </NavigationLink>
            <NavigationLink to='/public/local' iconComponent={FediIcon}>
              <FormattedMessage
                id='tabs_bar.fediverse_feeds'
                defaultMessage='Fediverse Feeds'
              />
            </NavigationLink>
          </ul>
          <footer className={classes.footer}>
            <ul className={classes.footerNav}>
              <NavigationLink
                stacked
                to='/notifications'
                iconComponent={BellIcon}
                badgeCount={notificationsCount}
              >
                <FormattedMessage
                  id='tabs_bar.notifications'
                  defaultMessage='Notifications'
                />
              </NavigationLink>
              <NavigationLink
                stacked
                to='/conversations'
                iconComponent={ChatCircleIcon}
              >
                <FormattedMessage
                  id='tabs_bar.messages'
                  defaultMessage='Messages'
                  description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
                />
              </NavigationLink>
              <NavigationLink
                stacked
                to='/bookmarks'
                iconComponent={BookmarkSimpleIcon}
              >
                <FormattedMessage id='tabs_bar.saved' defaultMessage='Saved' />
              </NavigationLink>
            </ul>
            <NavigationAccountCardAndMenu />
            <NavigationFooterLinks siteName={siteName} />
          </footer>
        </>
      )}
    </nav>
  );
};
