import { defineMessages, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import { Hashtag } from 'mastodon/components/hashtag';

export type TagMap = ImmutableMap<
  'id' | 'name' | 'url' | 'statuses_count' | 'last_status_at' | 'accountId',
  string | null
>;

interface FeaturedTagProps {
  tag: TagMap;
  account: string;
}

const messages = defineMessages({
  lastStatusAt: {
    id: 'account.featured_tags.last_status_at',
    defaultMessage: 'Last post on {date}',
  },
  empty: {
    id: 'account.featured_tags.last_status_never',
    defaultMessage: 'No posts',
  },
});

export const FeaturedTag: React.FC<FeaturedTagProps> = ({ tag, account }) => {
  const intl = useIntl();
  const name = tag.get('name') ?? '';
  const count = Number.parseInt(tag.get('statuses_count') ?? '');
  return (
    <Hashtag
      key={name}
      name={name}
      to={`/@${account}/tagged/${name}`}
      uses={count}
      withGraph={false}
      description={
        count > 0
          ? intl.formatMessage(messages.lastStatusAt, {
              date: intl.formatDate(tag.get('last_status_at') ?? '', {
                month: 'short',
                day: '2-digit',
                year: 'numeric',
              }),
            })
          : intl.formatMessage(messages.empty)
      }
    />
  );
};
