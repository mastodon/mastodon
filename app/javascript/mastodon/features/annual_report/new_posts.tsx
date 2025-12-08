import { FormattedNumber, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { TimeSeriesMonth } from 'mastodon/models/annual_report';

import styles from './index.module.scss';

export const NewPosts: React.FC<{
  data: TimeSeriesMonth[];
}> = ({ data }) => {
  const posts = data.reduce((sum, item) => sum + item.statuses, 0);

  return (
    <div className={classNames(styles.box, styles.newPosts, styles.content)}>
      <div className={styles.statLarge}>
        <FormattedNumber value={posts} />
      </div>

      <div className={styles.title}>
        <FormattedMessage
          id='annual_report.summary.new_posts.new_posts'
          defaultMessage='new posts'
        />
      </div>
    </div>
  );
};
