import { useCallback } from 'react';
import type { FC } from 'react';

import { useIntl } from 'react-intl';

import { resetCompose, focusCompose } from '@/mastodon/actions/compose';
import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import type { AnnualReport as AnnualReportData } from '@/mastodon/models/annual_report';
import { useAppDispatch } from '@/mastodon/store';

import { shareMessage } from '.';
import { archetypeNames } from './archetype';

export const ShareButton: FC<{ report: AnnualReportData }> = ({ report }) => {
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
