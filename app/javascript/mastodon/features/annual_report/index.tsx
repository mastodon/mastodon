import { useEffect, useState } from 'react';
import type { FC } from 'react';

import { defineMessage, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useLocation } from 'react-router';

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

export const shareMessage = defineMessage({
  id: 'annual_report.summary.share_message',
  defaultMessage: 'I got the {archetype} archetype!',
});

// Share = false when using the embedded version of the report.
export const AnnualReport: FC<{ context?: 'modal' | 'standalone' }> = ({
  context = 'standalone',
}) => {
  const dispatch = useAppDispatch();
  const currentAccount = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );
  const report = useAppSelector((state) => state.annualReport.report);

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

  const topHashtag = report.data.top_hashtags[0] ?? {
    name: 'mastodon',
    count: 12,
  };

  return (
    <div className={classNames(styles.wrapper, 'theme-dark')}>
      <div className={styles.header}>
        <h1>
          <FormattedMessage
            id='annual_report.summary.title'
            defaultMessage='Wrapstodon {year}'
            values={{ year: report.year }}
          />
        </h1>
        <p>
          <FormattedMessage
            id='annual_report.summary.here_it_is'
            defaultMessage='Here is your {year} in review:'
            values={{ year: report.year }}
          />
        </p>
      </div>

      <div className={styles.bento}>
        <HighlightedPost data={report.data.top_statuses} />
        <Followers
          data={report.data.time_series}
          total={currentAccount?.followers_count}
        />
        <MostUsedHashtag hashtag={topHashtag} />
        <NewPosts data={report.data.time_series} />
        <Archetype
          report={report}
          currentAccount={currentAccount}
          share={context === 'modal'}
        />
      </div>
    </div>
  );
};
