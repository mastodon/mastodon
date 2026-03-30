/* eslint-disable @typescript-eslint/no-unsafe-return,
                  @typescript-eslint/no-explicit-any,
                  @typescript-eslint/no-unsafe-assignment,
                  @typescript-eslint/no-unsafe-member-access,
                  @typescript-eslint/no-unsafe-call */

import type { ComponentPropsWithoutRef } from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { InterceptStatusClicks } from 'mastodon/components/status/intercept_status_clicks';
import { StatusQuoteManager } from 'mastodon/components/status_quoted';
import type { TopStatuses } from 'mastodon/models/annual_report';
import { makeGetStatus } from 'mastodon/selectors';
import { useAppSelector } from 'mastodon/store';

import styles from './index.module.scss';

const getStatus = makeGetStatus() as unknown as (arg0: any, arg1: any) => any;

export const HighlightedPost: React.FC<{
  data: TopStatuses;
  context: 'modal' | 'standalone';
}> = ({ data, context }) => {
  const { by_reblogs, by_favourites, by_replies } = data;

  const statusId = by_reblogs || by_favourites || by_replies;

  const status = useAppSelector((state) =>
    statusId ? getStatus(state, { id: statusId }) : undefined,
  );

  const handleClick = useCallback<
    ComponentPropsWithoutRef<typeof InterceptStatusClicks>['onPreventedClick']
  >(
    (clickedArea) => {
      const link: string =
        clickedArea === 'account'
          ? status.getIn(['account', 'url'])
          : status.get('url');

      if (context === 'standalone') {
        window.location.href = link;
      } else {
        window.open(link, '_blank');
      }
    },
    [status, context],
  );

  if (!status) {
    return null;
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
        {context === 'modal' && <p>{label}</p>}
      </div>

      <InterceptStatusClicks onPreventedClick={handleClick}>
        <StatusQuoteManager showActions={false} id={statusId} />
      </InterceptStatusClicks>
    </div>
  );
};
