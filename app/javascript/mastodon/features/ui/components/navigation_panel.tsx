import { useEffect, useCallback, useRef } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';
import { Link, useLocation } from 'react-router-dom';

import type { Map as ImmutableMap } from 'immutable';

import { animated, useSpring } from '@react-spring/web';
import { useDrag } from '@use-gesture/react';

import AddIcon from '@/material-icons/400-24px/add.svg?react';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import BookmarksActiveIcon from '@/material-icons/400-24px/bookmarks-fill.svg?react';
import BookmarksIcon from '@/material-icons/400-24px/bookmarks.svg?react';
import ExploreActiveIcon from '@/material-icons/400-24px/explore-fill.svg?react';
import ExploreIcon from '@/material-icons/400-24px/explore.svg?react';
import HomeActiveIcon from '@/material-icons/400-24px/home-fill.svg?react';
import HomeIcon from '@/material-icons/400-24px/home.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import LogoutIcon from '@/material-icons/400-24px/logout.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import PersonAddActiveIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';
import StarActiveIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarIcon from '@/material-icons/400-24px/star.svg?react';
import { fetchFollowRequests } from 'mastodon/actions/accounts';
import { openModal } from 'mastodon/actions/modal';
import { openNavigation, closeNavigation } from 'mastodon/actions/navigation';
import { Account } from 'mastodon/components/account';
import { IconButton } from 'mastodon/components/icon_button';
import { IconWithBadge } from 'mastodon/components/icon_with_badge';
import { WordmarkLogo } from 'mastodon/components/logo';
import { NavigationPortal } from 'mastodon/components/navigation_portal';
import { useBreakpoint } from 'mastodon/features/ui/hooks/useBreakpoint';
import { useIdentity } from 'mastodon/identity_context';
import { timelinePreview, trendsEnabled, me } from 'mastodon/initial_state';
import { transientSingleColumn } from 'mastodon/is_mobile';
import { selectUnreadNotificationGroupsCount } from 'mastodon/selectors/notifications';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { ColumnLink } from './column_link';
import DisabledAccountBanner from './disabled_account_banner';
import { ListPanel } from './list_panel';
import { MoreLink } from './more_link';
import SignInBanner from './sign_in_banner';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  explore: { id: 'explore.title', defaultMessage: 'Explore' },
  firehose: { id: 'column.firehose', defaultMessage: 'Live feeds' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Private mentions' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  followsAndFollowers: {
    id: 'navigation_bar.follows_and_followers',
    defaultMessage: 'Follows and followers',
  },
  about: { id: 'navigation_bar.about', defaultMessage: 'About' },
  search: { id: 'navigation_bar.search', defaultMessage: 'Search' },
  advancedInterface: {
    id: 'navigation_bar.advanced_interface',
    defaultMessage: 'Open in advanced web interface',
  },
  openedInClassicInterface: {
    id: 'navigation_bar.opened_in_classic_interface',
    defaultMessage:
      'Posts, accounts, and other specific pages are opened by default in the classic web interface.',
  },
  followRequests: {
    id: 'navigation_bar.follow_requests',
    defaultMessage: 'Follow requests',
  },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  compose: { id: 'tabs_bar.publish', defaultMessage: 'New Post' },
});

const NotificationsLink = () => {
  const count = useAppSelector(selectUnreadNotificationGroupsCount);
  const intl = useIntl();

  return (
    <ColumnLink
      key='notifications'
      transparent
      to='/notifications'
      icon={
        <IconWithBadge
          id='bell'
          icon={NotificationsIcon}
          count={count}
          className='column-link__icon'
        />
      }
      activeIcon={
        <IconWithBadge
          id='bell'
          icon={NotificationsActiveIcon}
          count={count}
          className='column-link__icon'
        />
      }
      text={intl.formatMessage(messages.notifications)}
    />
  );
};

const FollowRequestsLink: React.FC = () => {
  const intl = useIntl();
  const count = useAppSelector(
    (state) =>
      (
        state.user_lists.getIn(['follow_requests', 'items']) as
          | ImmutableMap<string, unknown>
          | undefined
      )?.size ?? 0,
  );
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(fetchFollowRequests());
  }, [dispatch]);

  if (count === 0) {
    return null;
  }

  return (
    <ColumnLink
      transparent
      to='/follow_requests'
      icon={
        <IconWithBadge
          id='user-plus'
          icon={PersonAddIcon}
          count={count}
          className='column-link__icon'
        />
      }
      activeIcon={
        <IconWithBadge
          id='user-plus'
          icon={PersonAddActiveIcon}
          count={count}
          className='column-link__icon'
        />
      }
      text={intl.formatMessage(messages.followRequests)}
    />
  );
};

const SearchLink: React.FC = () => {
  const intl = useIntl();
  const showAsSearch = useBreakpoint('full');

  if (!trendsEnabled || showAsSearch) {
    return (
      <ColumnLink
        transparent
        to={trendsEnabled ? '/explore' : '/search'}
        icon='search'
        iconComponent={SearchIcon}
        text={intl.formatMessage(messages.search)}
      />
    );
  }

  return (
    <ColumnLink
      transparent
      to='/explore'
      icon='explore'
      iconComponent={ExploreIcon}
      activeIconComponent={ExploreActiveIcon}
      text={intl.formatMessage(messages.explore)}
    />
  );
};

const ProfileCard: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const handleLogoutClick = useCallback(() => {
    dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));
  }, [dispatch]);

  if (!me) {
    return null;
  }

  return (
    <div className='navigation-bar'>
      <Account id={me} minimal size={36} />
      <IconButton
        icon='sign-out'
        iconComponent={LogoutIcon}
        title={intl.formatMessage(messages.logout)}
        onClick={handleLogoutClick}
      />
    </div>
  );
};

const MENU_WIDTH = 284;

export const NavigationPanel: React.FC = () => {
  const intl = useIntl();
  const { signedIn, disabledAccountId } = useIdentity();
  const open = useAppSelector((state) => state.navigation.open);
  const dispatch = useAppDispatch();
  const openable = useBreakpoint('openable');
  const location = useLocation();
  const overlayRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    dispatch(closeNavigation());
  }, [dispatch, location]);

  useEffect(() => {
    const handleDocumentClick = (e: MouseEvent) => {
      if (overlayRef.current && e.target === overlayRef.current) {
        dispatch(closeNavigation());
      }
    };

    const handleDocumentKeyUp = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        dispatch(closeNavigation());
      }
    };

    document.addEventListener('click', handleDocumentClick);
    document.addEventListener('keyup', handleDocumentKeyUp);

    return () => {
      document.removeEventListener('click', handleDocumentClick);
      document.removeEventListener('keyup', handleDocumentKeyUp);
    };
  }, [dispatch]);

  const [{ x }, spring] = useSpring(
    () => ({
      x: open ? 0 : MENU_WIDTH,
      onRest: {
        x({ value }: { value: number }) {
          if (value === 0) {
            dispatch(openNavigation());
          } else if (value > 0) {
            dispatch(closeNavigation());
          }
        },
      },
    }),
    [open],
  );

  const bind = useDrag(
    ({ last, offset: [ox], velocity: [vx], direction: [dx], cancel }) => {
      if (ox < -70) {
        cancel();
      }

      if (last) {
        if (ox > MENU_WIDTH / 2 || (vx > 0.5 && dx > 0)) {
          void spring.start({ x: MENU_WIDTH });
        } else {
          void spring.start({ x: 0 });
        }
      } else {
        void spring.start({ x: ox, immediate: true });
      }
    },
    {
      from: () => [x.get(), 0],
      filterTaps: true,
      bounds: { left: 0 },
      rubberband: true,
    },
  );

  const isFirehoseActive = useCallback(
    (match: unknown, location: { pathname: string }): boolean => {
      return !!match || location.pathname.startsWith('/public');
    },
    [],
  );

  const previouslyFocusedElementRef = useRef<HTMLElement | null>();

  useEffect(() => {
    if (open) {
      const firstLink = document.querySelector<HTMLAnchorElement>(
        '.navigation-panel__menu .column-link',
      );
      previouslyFocusedElementRef.current =
        document.activeElement as HTMLElement;
      firstLink?.focus();
    } else {
      previouslyFocusedElementRef.current?.focus();
    }
  }, [open]);

  let banner = undefined;

  if (transientSingleColumn) {
    banner = (
      <div className='switch-to-advanced'>
        {intl.formatMessage(messages.openedInClassicInterface)}{' '}
        <a
          href={`/deck${location.pathname}`}
          className='switch-to-advanced__toggle'
        >
          {intl.formatMessage(messages.advancedInterface)}
        </a>
      </div>
    );
  }

  const showOverlay = openable && open;

  return (
    <div
      className={classNames(
        'columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational',
        { 'columns-area__panels__pane--overlay': showOverlay },
      )}
      ref={overlayRef}
    >
      <animated.div
        className='columns-area__panels__pane__inner'
        {...bind()}
        style={openable ? { x } : undefined}
      >
        <div className='navigation-panel'>
          <div className='navigation-panel__logo'>
            <Link to='/' className='column-link column-link--logo'>
              <WordmarkLogo />
            </Link>
          </div>

          <ProfileCard />

          {banner && <div className='navigation-panel__banner'>{banner}</div>}

          <div className='navigation-panel__menu'>
            {signedIn && (
              <>
                <ColumnLink
                  to='/publish'
                  icon='plus'
                  iconComponent={AddIcon}
                  activeIconComponent={AddIcon}
                  text={intl.formatMessage(messages.compose)}
                  className='button navigation-panel__compose-button'
                />
                <ColumnLink
                  transparent
                  to='/home'
                  icon='home'
                  iconComponent={HomeIcon}
                  activeIconComponent={HomeActiveIcon}
                  text={intl.formatMessage(messages.home)}
                />
                <NotificationsLink />
                <FollowRequestsLink />
              </>
            )}

            <SearchLink />

            {(signedIn || timelinePreview) && (
              <ColumnLink
                transparent
                to='/public/local'
                isActive={isFirehoseActive}
                icon='globe'
                iconComponent={PublicIcon}
                text={intl.formatMessage(messages.firehose)}
              />
            )}

            {!signedIn && (
              <div className='navigation-panel__sign-in-banner'>
                <hr />
                {disabledAccountId ? (
                  <DisabledAccountBanner />
                ) : (
                  <SignInBanner />
                )}
              </div>
            )}

            {signedIn && (
              <>
                <ColumnLink
                  transparent
                  to='/conversations'
                  icon='at'
                  iconComponent={AlternateEmailIcon}
                  text={intl.formatMessage(messages.direct)}
                />
                <ColumnLink
                  transparent
                  to='/bookmarks'
                  icon='bookmarks'
                  iconComponent={BookmarksIcon}
                  activeIconComponent={BookmarksActiveIcon}
                  text={intl.formatMessage(messages.bookmarks)}
                />
                <ColumnLink
                  transparent
                  to='/favourites'
                  icon='star'
                  iconComponent={StarIcon}
                  activeIconComponent={StarActiveIcon}
                  text={intl.formatMessage(messages.favourites)}
                />

                <ListPanel />

                <hr />

                <ColumnLink
                  transparent
                  href='/settings/preferences'
                  icon='cog'
                  iconComponent={SettingsIcon}
                  text={intl.formatMessage(messages.preferences)}
                />

                <MoreLink />
              </>
            )}

            <div className='navigation-panel__legal'>
              <hr />

              <ColumnLink
                transparent
                to='/about'
                icon='ellipsis-h'
                iconComponent={InfoIcon}
                text={intl.formatMessage(messages.about)}
              />
            </div>
          </div>

          <div className='flex-spacer' />

          <NavigationPortal />
        </div>
      </animated.div>
    </div>
  );
};
