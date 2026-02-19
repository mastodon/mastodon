import { FormattedNumber, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import styles from './index.module.scss';

export const NewPosts: React.FC<{
  count: number;
}> = ({ count }) => {
  return (
    <div className={classNames(styles.box, styles.newPosts, styles.content)}>
      <div className={styles.statLarge}>
        <FormattedNumber value={count} />
      </div>

      <div className={styles.title}>
        <FormattedMessage
          id='annual_report.summary.new_posts.new_posts'
          defaultMessage='{count, plural, one {new post} other {new posts}}'
          values={{ count }}
        />
      </div>
    </div>
  );
};
