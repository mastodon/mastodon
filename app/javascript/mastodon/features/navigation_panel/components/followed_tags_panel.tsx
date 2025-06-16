import { useEffect, useState } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { apiGetFollowedTags } from 'mastodon/api/tags';
import type { ApiHashtagJSON } from 'mastodon/api_types/tags';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';

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

export const FollowedTagsPanel: React.FC = () => {
  const intl = useIntl();
  const [tags, setTags] = useState<ApiHashtagJSON[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);

    void apiGetFollowedTags(undefined, 4)
      .then(({ tags }) => {
        setTags(tags);
        setLoading(false);

        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [setLoading, setTags]);

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
      {tags.map((tag) => (
        <ColumnLink
          icon='hashtag'
          key={tag.name}
          iconComponent={TagIcon}
          text={`#${tag.name}`}
          to={`/tags/${tag.name}`}
          transparent
        />
      ))}
    </CollapsiblePanel>
  );
};
