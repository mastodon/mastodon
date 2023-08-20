import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import Hashtag from 'mastodon/components/hashtag';
import { selectFeaturedTags } from 'mastodon/reducers/user_lists';
import { getAccount } from 'mastodon/selectors/accounts';
import { useAppSelector } from 'mastodon/store';

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

interface Props {
  accountId: string;
}

export const FeaturedTags = ({ accountId }: Props) => {
  const intl = useIntl();
  const account = useAppSelector((state) => getAccount(state, accountId));
  const featuredTags = useAppSelector(selectFeaturedTags(accountId));

  if (account === null || account.get('suspended') || featuredTags.isEmpty()) {
    return null;
  }

  return (
    <div className='getting-started__trends'>
      <h4>
        <FormattedMessage
          id='account.featured_tags.title'
          defaultMessage="{name}'s featured hashtags"
          values={{
            name: (
              <bdi
                dangerouslySetInnerHTML={{
                  __html: account.get('display_name_html'),
                }}
              />
            ),
          }}
        />
      </h4>

      {featuredTags.take(3).map((featuredTag) => (
        <Hashtag
          key={featuredTag.get('name')}
          name={featuredTag.get('name')}
          to={`/@${account.get('acct')}/tagged/${featuredTag.get('name')}`}
          uses={featuredTag.get('statuses_count') * 1}
          withGraph={false}
          description={
            featuredTag.get('statuses_count') * 1 > 0
              ? intl.formatMessage(messages.lastStatusAt, {
                  date: intl.formatDate(featuredTag.get('last_status_at'), {
                    month: 'short',
                    day: '2-digit',
                  }),
                })
              : intl.formatMessage(messages.empty)
          }
        />
      ))}
    </div>
  );
};
