import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  BookmarkSimpleIcon,
  CompassIcon,
  CaretLineRightIcon,
  MagnifyingGlassIcon,
  PenNibIcon,
} from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { trendsEnabled } from '@/mastodon/initial_state';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { openCollapsibleSidebar } from '@/mastodon/reducers/slices/navigation';
import { useAppDispatch } from '@/mastodon/store';

import { handleSearchLinkClick } from '.';
import classes from './collapsed.module.scss';
// import { useCustomFeeds, useFollowedHashtags } from './hooks';
import {
  MiniAccountLink,
  MiniHomeLink,
  MiniMessagesLink,
  MiniNotificationsLink,
} from './mini_nav';
import { MiniNavigationLink } from './navigation_link';

const messages = defineMessages({
  main: {
    id: 'navigation_bar.main',
    defaultMessage: 'Main',
    description:
      'Label for the main navigation; should not contain the word "navigation".',
  },
});

// const MAX_HASHTAG_COUNT = 10;

export const CollapsedNavigationPanel: React.FC<{
  multiColumn?: boolean;
}> = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  // const { customFeeds } = useCustomFeeds();
  // const { followedHashtags } = useFollowedHashtags();

  const expandNavigation = useCallback(() => {
    dispatch(openCollapsibleSidebar());
  }, [dispatch]);

  const openComposer = useCallback(() => {
    dispatch(openNewComposer({ type: 'post' }));
  }, [dispatch]);

  const tooltipPlacement = 'right';

  return (
    <nav
      className={classes.root}
      aria-label={intl.formatMessage(messages.main)}
    >
      <IconButton
        icon={CaretLineRightIcon}
        size='sm'
        tooltipPlacement={tooltipPlacement}
        onClick={expandNavigation}
        className={classes.expandButton}
      >
        <FormattedMessage
          id='navigation_bar.expand'
          defaultMessage='Expand Menu'
        />
      </IconButton>
      <ul className={classes.list}>
        <li>
          <MiniHomeLink tooltipPlacement={tooltipPlacement} />
        </li>
        <li>
          <MiniNavigationLink
            to={{
              pathname: '/search',
              state: { focusTarget: FOCUS_TARGET.SEARCH },
            }}
            onClick={handleSearchLinkClick}
            icon={MagnifyingGlassIcon}
            tooltipPlacement={tooltipPlacement}
          >
            <FormattedMessage id='tabs_bar.search' defaultMessage='Search' />
          </MiniNavigationLink>
        </li>
        <li>
          <MiniMessagesLink tooltipPlacement={tooltipPlacement} />
        </li>
        <li>
          <MiniNotificationsLink
            tooltipPlacement={tooltipPlacement}
            badgeType='dot'
          />
        </li>
        <li className={classes.itemWithBottomBorder}>
          <MiniAccountLink
            tooltipPlacement={tooltipPlacement}
            menuPlacement='right-start'
          />
        </li>

        <li className={classes.itemWithBottomBorder}>
          <IconButton
            icon={PenNibIcon}
            onClick={openComposer}
            variant='solid'
            color='accent'
            size='md'
            tooltipPlacement={tooltipPlacement}
          >
            <FormattedMessage id='tabs_bar.publish' defaultMessage='New Post' />
          </IconButton>
        </li>

        {trendsEnabled && (
          <li>
            <MiniNavigationLink
              to='/explore'
              icon={CompassIcon}
              tooltipPlacement={tooltipPlacement}
            >
              <FormattedMessage
                id='tabs_bar.explore'
                defaultMessage='Explore'
              />
            </MiniNavigationLink>
          </li>
        )}
        <li className={classes.itemWithBottomBorder}>
          <MiniNavigationLink
            to='/bookmarks'
            icon={BookmarkSimpleIcon}
            tooltipPlacement={tooltipPlacement}
          >
            <FormattedMessage
              id='navigation_bar.saved_posts'
              defaultMessage='Saved Posts'
            />
          </MiniNavigationLink>
        </li>

        {/* <ListSection
          id='custom-feeds'
          title={
            <FormattedMessage
              id='tabs_bar.custom_feeds'
              defaultMessage='Custom Feeds'
            />
          }
        >
          <NavigationLink key='new' to='/lists/new' icon={PlusIcon}>
            <FormattedMessage
              id='tabs_bar.create_custom_feed'
              defaultMessage='Create Feed'
            />
          </NavigationLink>
          {customFeeds.map((feed) => (
            <NavigationLink
              key={feed.id}
              to={`/lists/${feed.id}`}
              icon={RssSimpleIcon}
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
        )} */}
      </ul>
    </nav>
  );
};
