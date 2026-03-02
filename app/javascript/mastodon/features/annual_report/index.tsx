import { useCallback, useEffect, useState } from 'react';
import type { FC } from 'react';

import { useIntl } from 'react-intl';

import { useLocation } from 'react-router';

import classNames from 'classnames/bind';

import { closeModal } from '@/mastodon/actions/modal';
import { IconButton } from '@/mastodon/components/icon_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { getReport } from '@/mastodon/reducers/slices/annual_report';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { Archetype } from './archetype';
import { Followers } from './followers';
import { HighlightedPost } from './highlighted_post';
import styles from './index.module.scss';
import { MostUsedHashtag } from './most_used_hashtag';
import { NewPosts } from './new_posts';

const moduleClassNames = classNames.bind(styles);

export const accountSelector = createAppSelector(
  [(state) => state.accounts, (state) => state.annualReport.report],
  (accounts, report) => {
    if (report?.schema_version === 2) {
      return accounts.get(report.account_id);
    }
    return undefined;
  },
);

export const AnnualReport: FC<{ context?: 'modal' | 'standalone' }> = ({
  context = 'standalone',
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const report = useAppSelector((state) => state.annualReport.report);
  const account = useAppSelector(accountSelector);
  const needsReport = !report; // Make into boolean to avoid object comparison in deps.

  useEffect(() => {
    if (needsReport) {
      void dispatch(getReport());
    }
  }, [dispatch, needsReport]);

  const close = useCallback(() => {
    dispatch(closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }));
  }, [dispatch]);

  // Close modal when navigating away from within
  const { pathname } = useLocation();
  const [initialPathname] = useState(pathname);
  useEffect(() => {
    if (pathname !== initialPathname) {
      close();
    }
  }, [pathname, initialPathname, close]);

  if (needsReport) {
    return <LoadingIndicator />;
  }

  const newPostCount = report.data.time_series.reduce(
    (sum, item) => sum + item.statuses,
    0,
  );

  const newFollowerCount =
    context === 'modal' &&
    report.data.time_series.reduce((sum, item) => sum + item.followers, 0);

  const topHashtag = report.data.top_hashtags[0];

  return (
    <div className={styles.wrapper} data-color-scheme='dark'>
      <div className={styles.header}>
        <h1>Wrapstodon {report.year}</h1>
        {account && <p>@{account.acct}</p>}
        {context === 'modal' && (
          <IconButton
            title={intl.formatMessage({
              id: 'annual_report.summary.close',
              defaultMessage: 'Close',
            })}
            className={styles.closeButton}
            icon='close'
            iconComponent={CloseIcon}
            onClick={close}
          />
        )}
      </div>

      <div className={styles.stack}>
        <HighlightedPost data={report.data.top_statuses} context={context} />
        <div
          className={moduleClassNames(styles.statsGrid, {
            noHashtag: !topHashtag,
            onlyHashtag: !(newFollowerCount && newPostCount),
            singleNumber: !!newFollowerCount !== !!newPostCount,
          })}
        >
          {!!newFollowerCount && <Followers count={newFollowerCount} />}
          {!!newPostCount && <NewPosts count={newPostCount} />}
          {topHashtag && (
            <MostUsedHashtag
              hashtag={topHashtag}
              account={account}
              context={context}
            />
          )}
        </div>
        <Archetype report={report} account={account} context={context} />
      </div>
    </div>
  );
};
