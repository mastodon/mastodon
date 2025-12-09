/* eslint-disable @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-explicit-any,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access,
                  @typescript-eslint/no-unsafe-call */

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { StatusQuoteManager } from 'mastodon/components/status_quoted';
import type { TopStatuses } from 'mastodon/models/annual_report';
import { makeGetStatus } from 'mastodon/selectors';
import { useAppSelector } from 'mastodon/store';

import styles from './index.module.scss';

const getStatus = makeGetStatus() as unknown as (arg0: any, arg1: any) => any;

export const HighlightedPost: React.FC<{
  data: TopStatuses;
}> = ({ data }) => {
  const { by_reblogs, by_favourites, by_replies } = data;

  const statusId = by_reblogs || by_favourites || by_replies;

  const status = useAppSelector((state) =>
    statusId ? getStatus(state, { id: statusId }) : undefined,
  );

  if (!status) {
    return <div className={classNames(styles.box, styles.mostBoostedPost)} />;
  }

  let label;
  if (by_reblogs) {
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.boost_count'
        defaultMessage='This post was boosted {count, plural, one {once} other {# times}}.'
        values={{ count: status.get('reblogs_count') }}
      />
    );
  } else if (by_favourites) {
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.favourite_count'
        defaultMessage='This post was favorited {count, plural, one {once} other {# times}}.'
        values={{ count: status.get('favourites_count') }}
      />
    );
  } else {
    label = (
      <FormattedMessage
        id='annual_report.summary.highlighted_post.reply_count'
        defaultMessage='This post got {count, plural, one {one reply} other {# replies}}.'
        values={{ count: status.get('replies_count') }}
      />
    );
  }

  return (
    <div className={classNames(styles.box, styles.mostBoostedPost)}>
      <div className={styles.content}>
        <h2 className={styles.title}>
          <FormattedMessage
            id='annual_report.summary.highlighted_post.title'
            defaultMessage='Most popular post'
          />
        </h2>
        <p>{label}</p>
      </div>

      <StatusQuoteManager showActions={false} id={`${statusId}`} />
    </div>
  );
};
