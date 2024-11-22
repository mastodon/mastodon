import { useState, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  importFetchedStatuses,
  importFetchedAccounts,
} from 'mastodon/actions/importer';
import { apiRequestGet, apiRequestPost } from 'mastodon/api';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { me } from 'mastodon/initial_state';
import type { Account } from 'mastodon/models/account';
import type { AnnualReport as AnnualReportData } from 'mastodon/models/annual_report';
import type { Status } from 'mastodon/models/status';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { Archetype } from './archetype';
import { Followers } from './followers';
import { HighlightedPost } from './highlighted_post';
import { MostUsedHashtag } from './most_used_hashtag';
import { NewPosts } from './new_posts';
import { Percentile } from './percentile';

interface AnnualReportResponse {
  annual_reports: AnnualReportData[];
  accounts: Account[];
  statuses: Status[];
}

export const AnnualReport: React.FC<{
  year: string;
}> = ({ year }) => {
  const [response, setResponse] = useState<AnnualReportResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const currentAccount = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );
  const dispatch = useAppDispatch();

  useEffect(() => {
    setLoading(true);

    apiRequestGet<AnnualReportResponse>(`v1/annual_reports/${year}`)
      .then((data) => {
        dispatch(importFetchedStatuses(data.statuses));
        dispatch(importFetchedAccounts(data.accounts));

        setResponse(data);
        setLoading(false);

        return apiRequestPost(`v1/annual_reports/${year}/read`);
      })
      .catch(() => {
        setLoading(false);
      });
  }, [dispatch, year, setResponse, setLoading]);

  if (loading) {
    return <LoadingIndicator />;
  }

  const report = response?.annual_reports[0];

  if (!report) {
    return null;
  }

  return (
    <div className='annual-report'>
      <div className='annual-report__header'>
        <h1>
          <FormattedMessage
            id='annual_report.summary.thanks'
            defaultMessage='Thanks for being part of Mastodon!'
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

      <div className='annual-report__bento annual-report__summary'>
        <Archetype data={report.data.archetype} />
        <HighlightedPost data={report.data.top_statuses} />
        <Followers
          data={report.data.time_series}
          total={currentAccount?.followers_count}
        />
        <MostUsedHashtag data={report.data.top_hashtags} />
        <Percentile data={report.data.percentiles} />
        <NewPosts data={report.data.time_series} />
      </div>
    </div>
  );
};
