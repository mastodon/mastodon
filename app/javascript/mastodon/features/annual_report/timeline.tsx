import { useCallback } from 'react';
import type { FC } from 'react';

import { showAlert } from '@/mastodon/actions/alerts';
import { generateReport } from '@/mastodon/reducers/slices/annual_report';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AnnualReportAnnouncement } from './announcement';

export const AnnualReportTimeline: FC = () => {
  const { year, state } = useAppSelector((state) => state.annualReport);

  const dispatch = useAppDispatch();
  const handleBuildRequest = useCallback(() => {
    void dispatch(generateReport());
  }, [dispatch]);

  const handleOpen = useCallback(() => {
    dispatch(
      // TODO: Implement opening the annual report view when components are ready.
      showAlert({
        message: 'Not yet implemented.',
      }),
    );
  }, [dispatch]);

  if (!year || !state || state === 'ineligible') {
    return null;
  }

  return (
    <AnnualReportAnnouncement
      year={year.toString()}
      hasData={state === 'available'}
      isLoading={state === 'generating'}
      onRequestBuild={handleBuildRequest}
      onOpen={handleOpen}
    />
  );
};
