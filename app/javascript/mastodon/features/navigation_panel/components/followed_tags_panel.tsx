import { useEffect } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { fetchFollowedHashtags } from 'mastodon/actions/tags_typed';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';
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
});

const TAG_LIMIT = 5;

const neverMarkLinkActive = () => false;

export const FollowedTagsPanel: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { tags, stale, loading } = useAppSelector(
    (state) => state.followedTags,
  );

  useEffect(() => {
    if (stale) {
      void dispatch(fetchFollowedHashtags({ limit: TAG_LIMIT + 1 }));
    }
  }, [dispatch, stale]);

  const tagsToRender = tags.slice(0, TAG_LIMIT);
  const hasMoreTags = tags.length > TAG_LIMIT;

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
      {tagsToRender.map((tag) => (
        <ColumnLink
          icon='hashtag'
          key={tag.name}
          iconComponent={TagIcon}
          text={`#${tag.name}`}
          to={`/tags/${tag.name}`}
          transparent
        />
      ))}
      {hasMoreTags && (
        <ColumnLink
          icon='hashtag'
          iconComponent={TagIcon}
          text='View all'
          to='/followed_tags'
          isActive={neverMarkLinkActive}
          transparent
        />
      )}
    </CollapsiblePanel>
  );
};
