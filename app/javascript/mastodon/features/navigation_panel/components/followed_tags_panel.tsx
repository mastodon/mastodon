import { useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { fetchFollowedHashtags } from 'mastodon/actions/tags_typed';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';
import { getFollowedTagsSidebar } from 'mastodon/selectors/tags';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { CollapsiblePanel } from './collapsible_panel';

const messages = defineMessages({
  followedTags: {
    id: 'navigation_bar.followed_tags',
    defaultMessage: 'Followed hashtags',
  },
  expand: {
    id: 'navigation_panel.expand_followed_tags',
    defaultMessage: 'Expand followed hashtags menu',
  },
  collapse: {
    id: 'navigation_panel.collapse_followed_tags',
    defaultMessage: 'Collapse followed hashtags menu',
  },
  viewAll: {
    id: 'navigation_panel.view_all_followed_tags',
    defaultMessage: 'View all',
  },
});

const TAG_LIMIT = 5;

export const FollowedTagsPanel: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { tags, stale, loading } = useAppSelector((state) =>
    getFollowedTagsSidebar(state),
  );
  const hasMoreTags = tags.length > TAG_LIMIT;

  useEffect(() => {
    if (stale) {
      void dispatch(
        fetchFollowedHashtags({ context: 'sidebar', limit: TAG_LIMIT + 1 }),
      );
    }
  }, [dispatch, stale]);

  return (
    <CollapsiblePanel
      to='/followed_tags'
      icon='hashtag'
      iconComponent={TagIcon}
      title={intl.formatMessage(messages.followedTags)}
      collapseTitle={intl.formatMessage(messages.collapse)}
      expandTitle={intl.formatMessage(messages.expand)}
      loading={loading}
    >
      {tags.slice(0, TAG_LIMIT).map((tag) => (
        <ColumnLink
          transparent
          icon='hashtag'
          key={tag.name}
          iconComponent={TagIcon}
          text={`#${tag.name}`}
          to={`/tags/${tag.name}`}
        />
      ))}
      {hasMoreTags && (
        <ColumnLink
          small
          transparent
          icon='hashtag'
          iconComponent={TagIcon}
          text={intl.formatMessage(messages.viewAll)}
          to='/followed_tags'
        />
      )}
    </CollapsiblePanel>
  );
};
