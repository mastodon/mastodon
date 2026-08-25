import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  PenNibIcon,
  HouseIcon,
  MagnifyingGlassIcon,
  RssSimpleIcon,
  BellIcon,
  ChatCircleIcon,
  BookmarkSimpleIcon,
} from '@phosphor-icons/react';

import FediIcon from '@/images/icons/icon_fediverse.svg?react';
import { fetchLists } from '@/mastodon/actions/lists';
import { fetchFollowedHashtags } from '@/mastodon/actions/tags_typed';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { useIdentity } from '@/mastodon/identity_context';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { getOrderedLists } from '@/mastodon/selectors/lists';
import { selectUnreadNotificationGroupsCount } from '@/mastodon/selectors/notifications';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { NavigationAccountCardAndMenu } from './account_card_and_menu';
import { NavigationFooterLinks } from './footer_links';
import { NavigationHeader } from './header';
import { ListSection } from './list_section';
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
  const customFeeds = useAppSelector((state) => getOrderedLists(state));

  useEffect(() => {
    void dispatch(fetchLists());
  }, [dispatch]);

  return {
    customFeeds,
  };
}

function useFollowedHashtags() {
  const dispatch = useAppDispatch();
  const { tags, stale } = useAppSelector((state) => state.followedTags);

  useEffect(() => {
    if (stale) {
      void dispatch(fetchFollowedHashtags());
    }
  }, [dispatch, stale]);

  return { followedHashtags: tags };
}

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

  const { customFeeds } = useCustomFeeds();
  const { followedHashtags } = useFollowedHashtags();

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
            <NavigationLink
              to={{
                pathname: '/explore',
                state: { focusTarget: FOCUS_TARGET.SEARCH },
              }}
              iconComponent={MagnifyingGlassIcon}
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
            >
              <FormattedMessage
                id='tabs_bar.fediverse_feeds'
                defaultMessage='Fediverse Feeds'
              />
            </NavigationLink>
            <ListSection
              title={
                <FormattedMessage
                  id='tabs_bar.custom_feeds'
                  defaultMessage='Custom feeds'
                />
              }
              action={{
                label: (
                  <FormattedMessage
                    id='tabs_bar.create_custom_feed'
                    defaultMessage='Create feed'
                  />
                ),
                link: '/lists/new',
              }}
              emptyMessage={
                <FormattedMessage
                  id='tabs_bar.custom_feeds_empty'
                  defaultMessage='You have no custom feeds yet.'
                />
              }
            >
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
                title={
                  <FormattedMessage
                    id='navigation_bar.followed_tags'
                    defaultMessage='Followed hashtags'
                  />
                }
                action={{
                  label: (
                    <FormattedMessage
                      id='navigation_bar.followed_tags_view_all'
                      defaultMessage='View all'
                    />
                  ),
                  link: '/followed_tags',
                }}
              >
                {followedHashtags.slice(0, 4).map((tag) => (
                  <NavigationLink key={tag.name} to={`/tags/${tag.name}`}>
                    #{tag.name}
                  </NavigationLink>
                ))}
              </ListSection>
            )}
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
