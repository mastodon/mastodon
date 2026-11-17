import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import {
  RssSimpleIcon,
  BookmarkSimpleIcon,
  PlusIcon,
  InfoIcon,
  GavelIcon,
  ShieldStarIcon,
  CompassIcon,
} from '@phosphor-icons/react';

import { Callout } from '@/mastodon/components/callout/redesign';
import { useScrollSensor } from '@/mastodon/hooks/useScrollSensor';
import { useIdentity } from '@/mastodon/identity_context';
import { disabledAccountId, trendsEnabled } from '@/mastodon/initial_state';
import { transientSingleColumn } from '@/mastodon/is_mobile';
import {
  canManageReports,
  canViewAdminDashboard,
} from '@/mastodon/permissions';
import { invokeVirtualIosKeyboard } from '@/mastodon/utils/invoke_virtual_ios_keyboard';

import { CollapsedNavigationPanel } from './collapsed';
import { FooterLinks } from './footer_links';
import { NavigationHeader } from './header';
import {
  useCustomFeeds,
  useFollowedHashtags,
  usePublicFeedsLink,
} from './hooks';
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

const MAX_HASHTAG_COUNT = 5;

interface NavigationPanelProps {
  siteName?: string;
  /**
   * In 'slide-out' mode (used on mobile), some menu items
   * are hidden and the design is tweaked slightly
   */
  mode?: 'static' | 'slide-out';
  multiColumn?: boolean;
  collapsed?: boolean;
  onToggleCollapsed?: () => void;
}

export const NavigationPanel: React.FC<NavigationPanelProps> = (props) => {
  const { mode = 'static', multiColumn, collapsed, onToggleCollapsed } = props;

  if (mode === 'static' && collapsed) {
    return (
      <CollapsedNavigationPanel
        multiColumn={multiColumn}
        onToggleCollapsed={onToggleCollapsed}
      />
    );
  } else {
    return <ExpandedNavigationPanel {...props} />;
  }
};

const ExpandedNavigationPanel: React.FC<NavigationPanelProps> = ({
  siteName,
  mode = 'static',
  multiColumn,
  onToggleCollapsed,
}) => {
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

  const explore = trendsEnabled && (
    <NavigationLink to='/explore' icon={CompassIcon}>
      <FormattedMessage id='tabs_bar.explore' defaultMessage='Explore' />
    </NavigationLink>
  );

  const publicFeedsLink = usePublicFeedsLink();
  const publicFeeds = publicFeedsLink && (
    <NavigationLink
      to={publicFeedsLink.link}
      icon={publicFeedsLink.icon}
      isActive={publicFeedsLink.isActive}
    >
      {publicFeedsLink.label}
    </NavigationLink>
  );

  return (
    <nav
      className={classes.root}
      data-mode={mode}
      data-scrollable={!isScrolledToTop || !isScrolledToBottom}
      aria-label={intl.formatMessage(messages.main)}
    >
      {topSensor}
      <NavigationHeader
        siteName={siteName}
        isStuck={!isScrolledToTop}
        onToggleCollapsed={onToggleCollapsed}
        mode={mode}
      />
      {signedIn && (
        <>
          {transientSingleColumn && <TransientSingleColumnCallout />}
          <ul className={classes.list}>
            {explore}
            {publicFeeds}
            <NavigationLink to='/bookmarks' icon={BookmarkSimpleIcon}>
              <FormattedMessage
                id='navigation_bar.saved_posts'
                defaultMessage='Saved Posts'
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
            )}

            {isAdmin && (
              <NavigationLink
                withDivider
                as='a'
                href='/admin/dashboard'
                icon={GavelIcon}
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
                icon={ShieldStarIcon}
              >
                <FormattedMessage
                  id='navigation_bar.moderation'
                  defaultMessage='Moderation'
                />
              </NavigationLink>
            )}
          </ul>

          <footer className={classes.footer}>
            <FooterLinks multiColumn={multiColumn} />
          </footer>
        </>
      )}
      {!signedIn && (
        <>
          <ul className={classes.list}>
            <NavigationLink to='/about' icon={InfoIcon}>
              <FormattedMessage
                id='footer.about_this_server'
                defaultMessage='About'
              />
            </NavigationLink>
            {explore}
            {publicFeeds}
          </ul>
          <footer className={classes.footer}>
            {disabledAccountId ? <DisabledAccountBanner /> : <LoggedOutInfo />}
            <FooterLinks multiColumn={multiColumn} />
          </footer>
        </>
      )}
      <div
        className={classes.bottomScrollFade}
        data-stuck={!isScrolledToBottom}
      />
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
