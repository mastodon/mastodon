import { useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import {
  RssSimpleIcon,
  BookmarkSimpleIcon,
  PlusIcon,
  InfoIcon,
  GavelIcon,
  ShieldStarIcon,
  CompassIcon,
} from '@phosphor-icons/react';

import FediIcon from '@/images/icons/icon_fediverse.svg?react';
import { fetchFollowRequests } from '@/mastodon/actions/accounts';
import { fetchLists } from '@/mastodon/actions/lists';
import { fetchFollowedHashtags } from '@/mastodon/actions/tags_typed';
import { Callout } from '@/mastodon/components/callout/redesign';
import { useHasAnnouncements } from '@/mastodon/features/announcements/hooks';
import { useScrollSensor } from '@/mastodon/hooks/useScrollSensor';
import { useIdentity } from '@/mastodon/identity_context';
import {
  disabledAccountId,
  localLiveFeedAccess,
  remoteLiveFeedAccess,
  trendsEnabled,
} from '@/mastodon/initial_state';
import { transientSingleColumn } from '@/mastodon/is_mobile';
import {
  canManageReports,
  canViewAdminDashboard,
  canViewFeed,
} from '@/mastodon/permissions';
import { getOrderedLists } from '@/mastodon/selectors/lists';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { invokeVirtualIosKeyboard } from '@/mastodon/utils/invoke_virtual_ios_keyboard';

import { FooterLinks } from './footer_links';
import { NavigationHeader } from './header';
import { ListSection } from './list_section';
import { DisabledAccountBanner, LoggedOutInfo } from './logged_out_info';
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

function useCustomFeeds() {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const customFeeds = useAppSelector((state) => getOrderedLists(state));

  useEffect(() => {
    if (signedIn) {
      void dispatch(fetchLists());
    }
  }, [dispatch, signedIn]);

  return {
    customFeeds,
  };
}

function useFollowedHashtags() {
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const { tags, stale } = useAppSelector((state) => state.followedTags);

  useEffect(() => {
    if (stale && signedIn) {
      void dispatch(fetchFollowedHashtags());
    }
  }, [dispatch, stale, signedIn]);

  return { followedHashtags: tags };
}

export function useFollowRequestsCount({
  fetch = true,
}: { fetch?: boolean } = {}) {
  const followRequestsCount = useAppSelector(
    (state) =>
      (
        state.user_lists.getIn(['follow_requests', 'items']) as
          | ImmutableMap<string, unknown>
          | undefined
      )?.size ?? 0,
  );
  const dispatch = useAppDispatch();

  useEffect(() => {
    if (fetch) {
      dispatch(fetchFollowRequests());
    }
  }, [dispatch, fetch]);

  return followRequestsCount;
}

export function useNotificationsCount() {
  const unreadNotificationsCount = useAppSelector(
    selectUnreadNotificationGroupsCount,
  );
  const { signedIn } = useIdentity();
  const followRequestsCount = useFollowRequestsCount({ fetch: signedIn });

  const { unreadAnnouncementCount } = useHasAnnouncements({ fetch: signedIn });

  return (
    unreadNotificationsCount + followRequestsCount + unreadAnnouncementCount
  );
}

const isFediverseFeedsLinkActive = (
  match: unknown,
  { pathname }: { pathname: string },
) => {
  return !!match || pathname.startsWith('/public');
};

const MAX_HASHTAG_COUNT = 5;

export const NavigationPanel: React.FC<{
  siteName?: string;
  /**
   * In 'slide-out' mode (used on smaller viewport sizes), some
   * menu items are hidden and the design is tweaked slightly
   */
  mode?: 'static' | 'slide-out';
  multiColumn?: boolean;
}> = ({ siteName, mode = 'static', multiColumn }) => {
  const intl = useIntl();
  const { signedIn, permissions } = useIdentity();

  const isManager = canManageReports(permissions);
  const isAdmin = canViewAdminDashboard(permissions);

  const { customFeeds } = useCustomFeeds();
  const { followedHashtags } = useFollowedHashtags();

  const { sensor: topSensor, isInViewport: isScrolledToTop } = useScrollSensor({
    placement: 'top',
    tolerance: 2,
  });
  const { sensor: bottomSensor, isInViewport: isScrolledToBottom } =
    useScrollSensor({
      placement: 'bottom',
    });

  return (
    <nav
      className={classes.root}
      data-mode={mode}
      data-scrollable={!isScrolledToTop || !isScrolledToBottom}
      aria-label={intl.formatMessage(messages.main)}
    >
      {topSensor}
      <NavigationHeader siteName={siteName} isStuck={!isScrolledToTop} />
      {signedIn && (
        <>
          {transientSingleColumn && <TransientSingleColumnCallout />}
          <ul className={classes.list}>
            <ExploreLink />
            <PublicFeedsLink />
            <NavigationLink to='/bookmarks' iconComponent={BookmarkSimpleIcon}>
              <FormattedMessage id='tabs_bar.saved' defaultMessage='Saved' />
            </NavigationLink>

            <ListSection
              id='custom-feeds'
              title={
                <FormattedMessage
                  id='tabs_bar.custom_feeds'
                  defaultMessage='Custom Feeds'
                />
              }
            >
              <NavigationLink
                key='new'
                to='/lists/new'
                iconComponent={PlusIcon}
              >
                <FormattedMessage
                  id='tabs_bar.create_custom_feed'
                  defaultMessage='Create Feed'
                />
              </NavigationLink>
              {customFeeds.map((feed) => (
                <NavigationLink
                  key={feed.id}
                  to={`/lists/${feed.id}`}
                  iconComponent={RssSimpleIcon}
                >
                  {feed.title}
                </NavigationLink>
              ))}
            </ListSection>

            {followedHashtags.length > 0 && (
              <ListSection
                id='followed-hashtags'
                title={
                  <FormattedMessage
                    id='tabs_bar.followed_hashtags'
                    defaultMessage='Followed Hashtags'
                  />
                }
              >
                {followedHashtags.slice(0, MAX_HASHTAG_COUNT).map((tag) => (
                  <NavigationLink key={tag.name} to={`/tags/${tag.name}`}>
                    #{tag.name}
                  </NavigationLink>
                ))}
                {followedHashtags.length > MAX_HASHTAG_COUNT && (
                  <NavigationLink key='view-all' to='/followed_tags'>
                    <FormattedMessage
                      id='tabs_bar.followed_tags_view_all'
                      defaultMessage='View all'
                    />
                  </NavigationLink>
                )}
              </ListSection>
            )}

            {isAdmin && (
              <NavigationLink
                withDivider
                as='a'
                href='/admin/dashboard'
                iconComponent={GavelIcon}
              >
                <FormattedMessage
                  id='navigation_bar.administration'
                  defaultMessage='Administration'
                />
              </NavigationLink>
            )}

            {isManager && (
              <NavigationLink
                withDivider={!isAdmin}
                as='a'
                href='/admin/reports'
                iconComponent={ShieldStarIcon}
              >
                <FormattedMessage
                  id='navigation_bar.moderation'
                  defaultMessage='Moderation'
                />
              </NavigationLink>
            )}
          </ul>

          <footer className={classes.footer} data-stuck={!isScrolledToBottom}>
            <FooterLinks multiColumn={multiColumn} />
          </footer>
        </>
      )}
      {!signedIn && (
        <>
          <ul className={classes.list}>
            <NavigationLink to='/about' iconComponent={InfoIcon}>
              <FormattedMessage
                id='footer.about_this_server'
                defaultMessage='About'
              />
            </NavigationLink>
            <ExploreLink />
            <PublicFeedsLink />
          </ul>
          <footer className={classes.footer} data-stuck={!isScrolledToBottom}>
            {disabledAccountId ? <DisabledAccountBanner /> : <LoggedOutInfo />}
            <FooterLinks multiColumn={multiColumn} />
          </footer>
        </>
      )}
      {bottomSensor}
    </nav>
  );
};

const ExploreLink: React.FC = () => {
  if (!trendsEnabled) return null;

  return (
    <NavigationLink
      to='/explore'
      iconComponent={CompassIcon}
      onClick={handleSearchLinkClick}
    >
      <FormattedMessage id='tabs_bar.explore' defaultMessage='Explore' />
    </NavigationLink>
  );
};

export function handleSearchLinkClick() {
  const mainSearchInput = document.querySelector<HTMLInputElement>(
    '[data-column-root] input[data-main-search]',
  );

  // Focus the main search input if we're already on the search page
  if (mainSearchInput) {
    mainSearchInput.focus();
    return;
  }

  // Otherwise, the search element is not on screen yet and
  // the page needs to be rendered first. In this case, we use
  // `invokeVirtualIosKeyboard` to work around an iOS quirk that
  // prevents the virtual keyboard from opening when an element wasn't
  // focused synchronously.
  invokeVirtualIosKeyboard();
}

const PublicFeedsLink: React.FC = () => {
  const { signedIn, permissions } = useIdentity();

  const canViewLocalFeed = canViewFeed(
    signedIn,
    permissions,
    localLiveFeedAccess,
  );
  const canViewRemoteFeed = canViewFeed(
    signedIn,
    permissions,
    remoteLiveFeedAccess,
  );

  if (!canViewLocalFeed && !canViewRemoteFeed) {
    return null;
  }

  const canViewOnlyOneFeed = canViewLocalFeed !== canViewRemoteFeed;

  return (
    <NavigationLink
      to={canViewLocalFeed ? '/public/local' : '/public/remote'}
      iconComponent={FediIcon}
      isActive={isFediverseFeedsLinkActive}
    >
      {canViewOnlyOneFeed ? (
        <FormattedMessage
          id='tabs_bar.public_feed'
          defaultMessage='Public Feed'
        />
      ) : (
        <FormattedMessage
          id='tabs_bar.public_feeds'
          defaultMessage='Public Feeds'
        />
      )}
    </NavigationLink>
  );
};

const TransientSingleColumnCallout: React.FC = () => (
  <Callout className={classes.callout}>
    <FormattedMessage
      id='navigation_bar.opened_in_single_column_layout'
      defaultMessage='Posts, profiles, and other pages are opened in the single-column layout by default.'
    />
    <br />
    <a href={`/deck${location.pathname}`}>
      <FormattedMessage
        id='navigation_bar.advanced_interface'
        defaultMessage='Open in advanced web interface'
      />
    </a>
  </Callout>
);
