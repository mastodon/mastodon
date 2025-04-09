import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { List as ImmutableList } from 'immutable';
import type { Map as ImmutableMap } from 'immutable';

import { Hashtag } from 'mastodon/components/hashtag';
import { useAppSelector } from 'mastodon/store';

type TagMap = ImmutableMap<
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

export const FeaturedTags: React.FC<{ accountId?: string }> = ({
  accountId,
}) => {
  const account = useAppSelector(
    (state) => state.accounts.get(accountId ?? '') ?? null,
  );
  const featuredTags = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_tags', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<TagMap>,
  );

  if (!accountId || !account || featuredTags.isEmpty()) {
    return null;
  }

  return (
    <>
      <h4>
        <FormattedMessage
          id='account.featured.hashtags'
          defaultMessage='Hashtags'
        />
      </h4>
      {featuredTags.map((tag) => (
        <FeaturedTag key={tag.get('id')} tag={tag} account={account.acct} />
      ))}
    </>
  );
};

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
              }),
            })
          : intl.formatMessage(messages.empty)
      }
    />
  );
};
