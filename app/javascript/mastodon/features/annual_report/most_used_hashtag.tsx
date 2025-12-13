import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { NameAndCount } from 'mastodon/models/annual_report';

import styles from './index.module.scss';

export const MostUsedHashtag: React.FC<{
  hashtag: NameAndCount;
  name: string | undefined;
  context: 'modal' | 'standalone';
}> = ({ hashtag, name, context }) => {
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
        {context === 'modal' ? (
          <FormattedMessage
            id='annual_report.summary.most_used_hashtag.used_count'
            defaultMessage='You included this hashtag in {count, plural, one {one post} other {# posts}}.'
            values={{ count: hashtag.count }}
          />
        ) : (
          name && (
            <FormattedMessage
              id='annual_report.summary.most_used_hashtag.used_count_public'
              defaultMessage='{name} included this hashtag in {count, plural, one {one post} other {# posts}}.'
              values={{ count: hashtag.count, name }}
            />
          )
        )}
      </p>
    </div>
  );
};
