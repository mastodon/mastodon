import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { DisplayName } from '@/mastodon/components/display_name';
import type { Account } from '@/mastodon/models/account';
import type { NameAndCount } from 'mastodon/models/annual_report';

import styles from './index.module.scss';

export const MostUsedHashtag: React.FC<{
  hashtag: NameAndCount;
  context: 'modal' | 'standalone';
  account?: Account;
}> = ({ hashtag, context, account }) => {
  return (
    <div
      className={classNames(styles.box, styles.mostUsedHashtag, styles.content)}
    >
      <div className={styles.title}>
        <FormattedMessage
          id='annual_report.summary.most_used_hashtag.most_used_hashtag'
          defaultMessage='Most used hashtag'
        />
      </div>

      <div className={styles.statExtraLarge}>#{hashtag.name}</div>

      <p>
        {context === 'modal' && (
          <FormattedMessage
            id='annual_report.summary.most_used_hashtag.used_count'
            defaultMessage='You included this hashtag in {count, plural, one {one post} other {# posts}}.'
            values={{ count: hashtag.count }}
          />
        )}
        {context !== 'modal' && account && (
          <FormattedMessage
            id='annual_report.summary.most_used_hashtag.used_count_public'
            defaultMessage='{name} included this hashtag in {count, plural, one {one post} other {# posts}}.'
            values={{
              count: hashtag.count,
              name: <DisplayName variant='simple' account={account} />,
            }}
          />
        )}
      </p>
    </div>
  );
};
