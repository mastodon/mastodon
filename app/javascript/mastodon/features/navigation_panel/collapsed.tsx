import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import {
  BookmarkSimpleIcon,
  CompassIcon,
  CaretLineRightIcon,
  MagnifyingGlassIcon,
  PenNibIcon,
  PlusIcon,
  RssSimpleIcon,
  ArrowUpRightIcon,
  HashIcon,
} from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button';
import {
  Menu,
  MenuItemGroup,
  MenuItemLink,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import { FOCUS_TARGET } from '@/mastodon/components/navigation_focus_target';
import { trendsEnabled } from '@/mastodon/initial_state';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { useAppDispatch } from '@/mastodon/store';

import { handleSearchLinkClick } from '.';
import classes from './collapsed.module.scss';
import {
  useCustomFeeds,
  useFollowedHashtags,
  usePublicFeedsLink,
} from './hooks';
import {
  MiniAccountLink,
  MiniHomeLink,
  MiniMessagesLink,
  MiniNotificationsLink,
} from './mini_nav';
import type { MiniNavigationLinkProps } from './navigation_link';
import { MiniNavigationLink } from './navigation_link';

const messages = defineMessages({
  main: {
    id: 'navigation_bar.main',
    defaultMessage: 'Main',
    description:
      'Label for the main navigation; should not contain the word "navigation".',
  },
});

const MAX_MENU_ITEM_COUNT = 10;

export const CollapsedNavigationPanel: React.FC<{
  multiColumn?: boolean;
  onToggleCollapsed?: () => void;
}> = ({ onToggleCollapsed }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { customFeeds } = useCustomFeeds();
  const { followedHashtags } = useFollowedHashtags();

  const publicFeedsLink = usePublicFeedsLink();

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
        onClick={onToggleCollapsed}
        className={classNames(classes.expandButton, 'rtl-flip')}
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
        {publicFeedsLink && (
          <MiniNavigationLink
            to={publicFeedsLink.link}
            icon={publicFeedsLink.icon}
            isActive={publicFeedsLink.isActive}
            tooltipPlacement={tooltipPlacement}
          >
            {publicFeedsLink.label}
          </MiniNavigationLink>
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

        <li>
          <MenuSection
            icon={RssSimpleIcon}
            title={
              <FormattedMessage
                id='tabs_bar.custom_feeds'
                defaultMessage='Custom Feeds'
              />
            }
          >
            <MenuItemLink to='/lists/new' icon={PlusIcon}>
              <FormattedMessage
                id='tabs_bar.create_custom_feed'
                defaultMessage='Create Feed'
              />
            </MenuItemLink>

            {customFeeds.slice(0, MAX_MENU_ITEM_COUNT).map((feed) => (
              <MenuItemLink
                key={feed.id}
                to={`/lists/${feed.id}`}
                icon={RssSimpleIcon}
              >
                {feed.title}
              </MenuItemLink>
            ))}

            {customFeeds.length > MAX_MENU_ITEM_COUNT && (
              <MenuItemLink key='view-all' to='/lists' icon={ArrowUpRightIcon}>
                <FormattedMessage
                  id='tabs_bar.followed_tags_view_all'
                  defaultMessage='View all'
                />
              </MenuItemLink>
            )}
          </MenuSection>
        </li>

        {followedHashtags.length > 0 && (
          <li>
            <MenuSection
              icon={HashIcon}
              title={
                <FormattedMessage
                  id='tabs_bar.followed_hashtags'
                  defaultMessage='Followed Hashtags'
                />
              }
            >
              {followedHashtags.slice(0, MAX_MENU_ITEM_COUNT).map((tag) => (
                <MenuItemLink key={tag.name} to={`/tags/${tag.name}`}>
                  #{tag.name}
                </MenuItemLink>
              ))}

              {followedHashtags.length > MAX_MENU_ITEM_COUNT && (
                <MenuItemLink
                  key='view-all'
                  to='/lists'
                  icon={ArrowUpRightIcon}
                >
                  <FormattedMessage
                    id='tabs_bar.followed_tags_view_all'
                    defaultMessage='View all'
                  />
                </MenuItemLink>
              )}
            </MenuSection>
          </li>
        )}
      </ul>
    </nav>
  );
};

const MenuSection: React.FC<{
  title: React.ReactNode;
  icon: MiniNavigationLinkProps['icon'];
  children: React.ReactNode;
}> = ({ title, icon, children }) => {
  return (
    <Menu type='navigation'>
      <MenuTrigger as={MiniNavigationLinkAsMenuButton} icon={icon}>
        {title}
      </MenuTrigger>
      <MenuList placement='right'>
        <MenuItemGroup label={title}>{children}</MenuItemGroup>
      </MenuList>
    </Menu>
  );
};

interface AccountButton
  extends
    React.ComponentPropsWithRef<'button'>,
    Pick<MiniNavigationLinkProps, 'icon'> {}

export const MiniNavigationLinkAsMenuButton: React.FC<AccountButton> = ({
  children,
  ...otherProps
}) => {
  return (
    <MiniNavigationLink
      as='button'
      withMenuIndicator
      tooltipPlacement='right'
      {...otherProps}
    >
      {children}
    </MiniNavigationLink>
  );
};
