import { useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { Dropdown } from 'mastodon/components/dropdown_menu';
import { useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  edit_profile: { id: 'account.edit_profile', defaultMessage: 'Edit profile' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  follow_requests: {
    id: 'navigation_bar.follow_requests',
    defaultMessage: 'Follow requests',
  },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  followed_tags: {
    id: 'navigation_bar.followed_tags',
    defaultMessage: 'Followed hashtags',
  },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: {
    id: 'navigation_bar.domain_blocks',
    defaultMessage: 'Blocked domains',
  },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  filters: { id: 'navigation_bar.filters', defaultMessage: 'Muted words' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
});

export const ActionBar: React.FC = () => {
  const dispatch = useAppDispatch();
  const intl = useIntl();

  const menu = useMemo(() => {
    const handleLogoutClick = () => {
      dispatch(openModal({ modalType: 'CONFIRM_LOG_OUT', modalProps: {} }));
    };

    return [
      {
        text: intl.formatMessage(messages.edit_profile),
        href: '/settings/profile',
      },
      {
        text: intl.formatMessage(messages.preferences),
        href: '/settings/preferences',
      },
      { text: intl.formatMessage(messages.pins), to: '/pinned' },
      null,
      {
        text: intl.formatMessage(messages.follow_requests),
        to: '/follow_requests',
      },
      { text: intl.formatMessage(messages.favourites), to: '/favourites' },
      { text: intl.formatMessage(messages.bookmarks), to: '/bookmarks' },
      { text: intl.formatMessage(messages.lists), to: '/lists' },
      {
        text: intl.formatMessage(messages.followed_tags),
        to: '/followed_tags',
      },
      null,
      { text: intl.formatMessage(messages.mutes), to: '/mutes' },
      { text: intl.formatMessage(messages.blocks), to: '/blocks' },
      {
        text: intl.formatMessage(messages.domain_blocks),
        to: '/domain_blocks',
      },
      { text: intl.formatMessage(messages.filters), href: '/filters' },
      null,
      { text: intl.formatMessage(messages.logout), action: handleLogoutClick },
    ];
  }, [intl, dispatch]);

  return <Dropdown items={menu} icon='bars' iconComponent={MoreHorizIcon} />;
};
