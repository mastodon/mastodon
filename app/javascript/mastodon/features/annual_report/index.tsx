import { useCallback } from 'react';
import type { FC } from 'react';

import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import { focusCompose, resetCompose } from '@/mastodon/actions/compose';
import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { me } from '@/mastodon/initial_state';
import type { AnnualReport as AnnualReportData } from '@/mastodon/models/annual_report';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { Archetype, archetypeNames } from './archetype';
import { Followers } from './followers';
import { HighlightedPost } from './highlighted_post';
import { MostUsedHashtag } from './most_used_hashtag';
import { NewPosts } from './new_posts';

const shareMessage = defineMessage({
  id: 'annual_report.summary.share_message',
  defaultMessage: 'I got the {archetype} archetype!',
});

// Share = false when using the embedded version of the report.
export const AnnualReport: FC<{ share?: boolean }> = ({ share = true }) => {
  const currentAccount = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );
  const report = useAppSelector((state) => state.annualReport.report);

  if (!report) {
    return <LoadingIndicator />;
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
        <NewPosts data={report.data.time_series} />
        {share && <ShareButton report={report} />}
      </div>
    </div>
  );
};

const ShareButton: FC<{ report: AnnualReportData }> = ({ report }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const handleShareClick = useCallback(() => {
    // Generate the share message.
    const archetypeName = intl.formatMessage(
      archetypeNames[report.data.archetype],
    );
    const shareLines = [
      intl.formatMessage(shareMessage, {
        archetype: archetypeName,
      }),
    ];
    // Share URL is only available for schema version 2.
    if (report.schema_version === 2 && report.share_url) {
      shareLines.push(report.share_url);
    }
    shareLines.push(`#Wrapstodon${report.year}`);

    // Reset the composer and focus it with the share message, then close the modal.
    dispatch(resetCompose());
    dispatch(focusCompose(shareLines.join('\n\n')));
    dispatch(closeModal({ modalType: 'ANNUAL_REPORT', ignoreFocus: false }));
  }, [report, intl, dispatch]);

  return <Button text='Share here' onClick={handleShareClick} />;
};
