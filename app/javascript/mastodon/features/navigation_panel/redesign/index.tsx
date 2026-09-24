import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import {
  PenNibIcon,
  HouseIcon,
  MagnifyingGlassIcon,
  RssSimpleIcon,
  BellIcon,
  ChatCircleDotsIcon,
  BookmarkSimpleIcon,
  PlusIcon,
} from '@phosphor-icons/react';

import FediIcon from '@/images/icons/icon_fediverse.svg?react';
import { fetchFollowRequests } from '@/mastodon/actions/accounts';
import { fetchLists } from '@/mastodon/actions/lists';
import { closeNavigation } from '@/mastodon/actions/navigation';
import { fetchFollowedHashtags } from '@/mastodon/actions/tags_typed';
import { Callout } from '@/mastodon/components/callout/redesign';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { useScrollSensor } from '@/mastodon/hooks/useScrollSensor';
import { useIdentity } from '@/mastodon/identity_context';
import { disabledAccountId } from '@/mastodon/initial_state';
import { transientSingleColumn } from '@/mastodon/is_mobile';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { getOrderedLists } from '@/mastodon/selectors/lists';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { invokeVirtualIosKeyboard } from '@/mastodon/utils/invoke_virtual_ios_keyboard';

import { useHasAnnouncements } from '../../announcements/hooks';

import { NavigationAccountCardAndMenu } from './account_card_and_menu';
import { NavigationFooterLinks } from './footer_links';
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
  const followRequestsCount = useFollowRequestsCount();

  const { unreadAnnouncementCount } = useHasAnnouncements();

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

export const RedesignNavigationPanel: React.FC<{
  siteName?: string;
  /**
   * In 'slide-out' mode (used on smaller viewport sizes), some
   * menu items are hidden and the design is tweaked slightly
   */
  mode?: 'static' | 'slide-out';
  multiColumn?: boolean;
}> = ({ siteName, mode = 'static', multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { signedIn } = useIdentity();
  const notificationsCount = useNotificationsCount();

  const openComposer = useCallback(() => {
    dispatch(closeNavigation());
    dispatch(openNewComposer({ type: 'post' }));
  }, [dispatch]);

  const { customFeeds } = useCustomFeeds();
  const { followedHashtags } = useFollowedHashtags();

  const { sensor: topSensor, isInViewport: isScrolledToTop } = useScrollSensor({
    placement: 'top',
    // Only show overlay fade after a bit of scrolling, as the nav header has
    // a bit of bottom spacing where the fade isn't needed yet
    tolerance: 36,
  });
  const { sensor: bottomSensor, isInViewport: isScrolledToBottom } =
    useScrollSensor({
      placement: 'bottom',
    });

  return (
    <nav
      className={classes.root}
      data-mode={mode}
      aria-label={intl.formatMessage(messages.main)}
    >
      {topSensor}
      <NavigationHeader siteName={siteName} isStuck={!isScrolledToTop} />
      {signedIn && (
        <>
          {transientSingleColumn && <TransientSingleColumnCallout />}
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
            <NavigationLink
              to={{
                pathname: '/explore',
                state: { focusTarget: FOCUS_TARGET.SEARCH },
              }}
              iconComponent={MagnifyingGlassIcon}
              onClick={invokeVirtualIosKeyboard}
            >
              <FormattedMessage
                id='tabs_bar.explore'
                defaultMessage='Explore'
              />
            </NavigationLink>
            <NavigationLink
              withSpaceAfter
              to='/public/local'
              iconComponent={FediIcon}
              isActive={isFediverseFeedsLinkActive}
            >
              <FormattedMessage
                id='tabs_bar.fediverse_feeds'
                defaultMessage='Fediverse Feeds'
              />
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
          </ul>
          <footer className={classes.footer} data-stuck={!isScrolledToBottom}>
            {mode !== 'slide-out' && (
              <>
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
                    iconComponent={ChatCircleDotsIcon}
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
                    <FormattedMessage
                      id='tabs_bar.saved'
                      defaultMessage='Saved'
                    />
                  </NavigationLink>
                </ul>
                <NavigationAccountCardAndMenu />
              </>
            )}
            <NavigationFooterLinks
              multiColumn={multiColumn}
              siteName={siteName}
            />
          </footer>
        </>
      )}
      {!signedIn && (
        <footer className={classes.footer} data-stuck={!isScrolledToBottom}>
          {disabledAccountId ? <DisabledAccountBanner /> : <LoggedOutInfo />}
          <NavigationFooterLinks
            multiColumn={multiColumn}
            siteName={siteName}
          />
        </footer>
      )}
      {bottomSensor}
    </nav>
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
