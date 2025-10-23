import { useEffect, useRef } from 'react';

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
import HomeActiveIcon from '@/material-icons/400-24px/home-fill.svg?react';
import HomeIcon from '@/material-icons/400-24px/home.svg?react';
import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import NotificationsActiveIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import NotificationsIcon from '@/material-icons/400-24px/notifications.svg?react';
import PersonAddActiveIcon from '@/material-icons/400-24px/person_add-fill.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import SettingsIcon from '@/material-icons/400-24px/settings.svg?react';
import StarActiveIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarIcon from '@/material-icons/400-24px/star.svg?react';
import TrendingUpIcon from '@/material-icons/400-24px/trending_up.svg?react';
import { fetchFollowRequests } from 'mastodon/actions/accounts';
import { openNavigation, closeNavigation } from 'mastodon/actions/navigation';
import { Account } from 'mastodon/components/account';
import { IconWithBadge } from 'mastodon/components/icon_with_badge';
import { WordmarkLogo } from 'mastodon/components/logo';
import { Search } from 'mastodon/features/compose/components/search';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';
import { useBreakpoint } from 'mastodon/features/ui/hooks/useBreakpoint';
import { useIdentity } from 'mastodon/identity_context';
import {
  localLiveFeedAccess,
  remoteLiveFeedAccess,
  trendsEnabled,
  me,
} from 'mastodon/initial_state';
import { transientSingleColumn } from 'mastodon/is_mobile';
import { canViewFeed } from 'mastodon/permissions';
import { selectUnreadNotificationGroupsCount } from 'mastodon/selectors/notifications';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { DisabledAccountBanner } from './components/disabled_account_banner';
import { FollowedTagsPanel } from './components/followed_tags_panel';
import { ListPanel } from './components/list_panel';
import { MoreLink } from './components/more_link';
import { SignInBanner } from './components/sign_in_banner';
import { Trends } from './components/trends';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  explore: { id: 'explore.title', defaultMessage: 'Trending' },
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
  searchTrends: {
    id: 'navigation_bar.search_trends',
    defaultMessage: 'Search / Trending',
  },
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

const ProfileCard: React.FC = () => {
  if (!me) {
    return null;
  }

  return (
    <div className='navigation-bar'>
      <Account id={me} minimal size={36} />
    </div>
  );
};

const isFirehoseActive = (
  match: unknown,
  { pathname }: { pathname: string },
) => {
  return !!match || pathname.startsWith('/public');
};

const MENU_WIDTH = 284;

export const NavigationPanel: React.FC<{ multiColumn?: boolean }> = ({
  multiColumn = false,
}) => {
  const intl = useIntl();
  const { signedIn, permissions, disabledAccountId } = useIdentity();
  const location = useLocation();
  const showSearch = useBreakpoint('full') && !multiColumn;

  let banner: React.ReactNode;

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

  return (
    <div className='navigation-panel'>
      <div className='navigation-panel__logo'>
        <Link to='/' className='column-link column-link--logo'>
          <WordmarkLogo />
        </Link>
      </div>

      {showSearch && <Search singleColumn />}

      {!multiColumn && <ProfileCard />}

      {banner && <div className='navigation-panel__banner'>{banner}</div>}

      <div className='navigation-panel__menu'>
        {signedIn && (
          <>
            {!multiColumn && (
              <ColumnLink
                to='/publish'
                icon='plus'
                iconComponent={AddIcon}
                activeIconComponent={AddIcon}
                text={intl.formatMessage(messages.compose)}
                className='button navigation-panel__compose-button'
              />
            )}
            <ColumnLink
              transparent
              to='/home'
              icon='home'
              iconComponent={HomeIcon}
              activeIconComponent={HomeActiveIcon}
              text={intl.formatMessage(messages.home)}
            />
          </>
        )}

        {trendsEnabled && (
          <ColumnLink
            transparent
            to='/explore'
            icon='explore'
            iconComponent={TrendingUpIcon}
            text={intl.formatMessage(messages.explore)}
          />
        )}

        {(canViewFeed(signedIn, permissions, localLiveFeedAccess) ||
          canViewFeed(signedIn, permissions, remoteLiveFeedAccess)) && (
          <ColumnLink
            transparent
            to={
              canViewFeed(signedIn, permissions, localLiveFeedAccess)
                ? '/public/local'
                : '/public/remote'
            }
            icon='globe'
            iconComponent={PublicIcon}
            isActive={isFirehoseActive}
            text={intl.formatMessage(messages.firehose)}
          />
        )}

        {signedIn && (
          <>
            <NotificationsLink />

            <FollowRequestsLink />

            <hr />

            <ListPanel />

            <FollowedTagsPanel />

            <ColumnLink
              transparent
              to='/favourites'
              icon='star'
              iconComponent={StarIcon}
              activeIconComponent={StarActiveIcon}
              text={intl.formatMessage(messages.favourites)}
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
              to='/conversations'
              icon='at'
              iconComponent={AlternateEmailIcon}
              text={intl.formatMessage(messages.direct)}
            />

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
          <ColumnLink
            transparent
            to='/about'
            icon='ellipsis-h'
            iconComponent={InfoIcon}
            text={intl.formatMessage(messages.about)}
          />
        </div>

        {!signedIn && (
          <div className='navigation-panel__sign-in-banner'>
            <hr />

            {disabledAccountId ? <DisabledAccountBanner /> : <SignInBanner />}
          </div>
        )}
      </div>

      <div className='flex-spacer' />

      <Trends />
    </div>
  );
};

export const CollapsibleNavigationPanel: React.FC = () => {
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

  const isLtrDir = getComputedStyle(document.body).direction !== 'rtl';

  const OPEN_MENU_OFFSET = isLtrDir ? MENU_WIDTH : -MENU_WIDTH;

  const [{ x }, spring] = useSpring(
    () => ({
      x: open ? 0 : OPEN_MENU_OFFSET,
      onRest: {
        x({ value }: { value: number }) {
          if (value === 0) {
            dispatch(openNavigation());
          } else if (isLtrDir ? value > 0 : value < 0) {
            dispatch(closeNavigation());
          }
        },
      },
    }),
    [open],
  );

  const bind = useDrag(
    ({
      last,
      offset: [xOffset],
      velocity: [xVelocity],
      direction: [xDirection],
      cancel,
    }) => {
      const logicalXDirection = isLtrDir ? xDirection : -xDirection;
      const logicalXOffset = isLtrDir ? xOffset : -xOffset;
      const hasReachedDragThreshold = logicalXOffset < -70;

      if (hasReachedDragThreshold) {
        cancel();
      }

      if (last) {
        const isAboveOpenThreshold = logicalXOffset > MENU_WIDTH / 2;
        const isQuickFlick = xVelocity > 0.5 && logicalXDirection > 0;

        if (isAboveOpenThreshold || isQuickFlick) {
          void spring.start({ x: OPEN_MENU_OFFSET });
        } else {
          void spring.start({ x: 0 });
        }
      } else {
        void spring.start({ x: xOffset, immediate: true });
      }
    },
    {
      from: () => [x.get(), 0],
      filterTaps: true,
      bounds: isLtrDir ? { left: 0 } : { right: 0 },
      rubberband: true,
      enabled: openable,
    },
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
        <NavigationPanel />
      </animated.div>
    </div>
  );
};
