import { FormattedMessage, FormattedNumber } from 'react-intl';

import classNames from 'classnames';

import type { TimeSeriesMonth } from 'mastodon/models/annual_report';

import styles from './index.module.scss';

export const Followers: React.FC<{
  data: TimeSeriesMonth[];
  total?: number;
}> = ({ data, total }) => {
  const change = data.reduce((sum, item) => sum + item.followers, 0);

  const showChange = change > 0;

  return (
    <div className={classNames(styles.box, styles.followers, styles.content)}>
      <div className={styles.statLarge}>
        <FormattedNumber value={showChange ? change : (total ?? 0)} />
      </div>

      <div className={styles.title}>
        {showChange ? (
          <FormattedMessage
            id='annual_report.summary.followers.new_followers'
            defaultMessage='new followers'
          />
        ) : (
          <FormattedMessage
            id='annual_report.summary.followers.followers'
            defaultMessage='followers'
          />
        )}
      </div>
    </div>
  );
};
