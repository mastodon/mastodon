import { useEffect, useState } from 'react';
import type { FC } from 'react';

import { defineMessage, FormattedMessage } from 'react-intl';

import { useLocation } from 'react-router';

import classNames from 'classnames/bind';

import { closeModal } from '@/mastodon/actions/modal';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { me } from '@/mastodon/initial_state';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { Archetype } from './archetype';
import { Followers } from './followers';
import { HighlightedPost } from './highlighted_post';
import styles from './index.module.scss';
import { MostUsedHashtag } from './most_used_hashtag';
import { NewPosts } from './new_posts';

const moduleClassNames = classNames.bind(styles);

export const shareMessage = defineMessage({
  id: 'annual_report.summary.share_message',
  defaultMessage: 'I got the {archetype} archetype!',
});

// Share = false when using the embedded version of the report.
export const AnnualReport: FC<{ context?: 'modal' | 'standalone' }> = ({
  context = 'standalone',
}) => {
  const dispatch = useAppDispatch();
  const report = useAppSelector((state) => state.annualReport.report);
  const account = useAppSelector((state) => {
    if (me) {
      return state.accounts.get(me);
    }
    if (report?.schema_version === 2) {
      return state.accounts.get(report.account_id);
    }
    return undefined;
  });

  console.log(report, account?.toJS());

  // Close modal when navigating away from within
  const { pathname } = useLocation();
  const [initialPathname] = useState(pathname);
  useEffect(() => {
    if (pathname !== initialPathname) {
      dispatch(closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }));
    }
  }, [pathname, initialPathname, dispatch]);

  if (!report) {
    return <LoadingIndicator />;
  }

  const newPostCount = report.data.time_series.reduce(
    (sum, item) => sum + item.statuses,
    0,
  );

  const newFollowerCount = report.data.time_series.reduce(
    (sum, item) => sum + item.followers,
    0,
  );

  const topHashtag = report.data.top_hashtags[0];
  //  ?? {
  //   name: 'mastodon',
  //   count: 12,
  // };

  return (
    <div className={moduleClassNames(styles.wrapper, 'theme-dark')}>
      <div className={styles.header}>
        <h1>
          <FormattedMessage
            id='annual_report.summary.title'
            defaultMessage='Wrapstodon {year}'
            values={{ year: report.year }}
          />
        </h1>
        {account && <p>@{account.acct}</p>}
      </div>

      <div className={styles.stack}>
        <HighlightedPost data={report.data.top_statuses} />
        <div
          className={moduleClassNames(styles.statsGrid, {
            noHashtag: !topHashtag,
            onlyHashtag: !(newFollowerCount && newPostCount),
            singleNumber: !!newFollowerCount !== !!newPostCount,
          })}
        >
          {!!newFollowerCount && <Followers count={newFollowerCount} />}
          {!!newPostCount && <NewPosts count={newPostCount} />}
          {topHashtag && <MostUsedHashtag hashtag={topHashtag} />}
        </div>
        <Archetype
          report={report}
          account={account}
          canShare={context === 'modal'}
        />
      </div>
    </div>
  );
};
