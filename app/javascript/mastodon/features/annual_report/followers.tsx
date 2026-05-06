import { FormattedMessage, FormattedNumber } from 'react-intl';

import classNames from 'classnames';

import styles from './index.module.scss';

export const Followers: React.FC<{
  count: number;
}> = ({ count }) => {
  return (
    <div className={classNames(styles.box, styles.followers, styles.content)}>
      <div className={styles.statLarge}>
        <FormattedNumber value={count} />
      </div>

      <div className={styles.title}>
        <FormattedMessage
          id='annual_report.summary.followers.new_followers'
          defaultMessage='{count, plural, one {new follower} other {new followers}}'
          values={{ count }}
        />
      </div>
    </div>
  );
};
