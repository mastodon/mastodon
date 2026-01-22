import { useEffect } from 'react';
import type { FC } from 'react';

import {
  expandTimelineByKey,
  timelineKey,
} from '@/mastodon/actions/timelines_typed';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { selectTimelineByKey } from '@/mastodon/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const AccountTimelineV2: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const key = timelineKey({ type: 'account', userId: accountId ?? '' });
  const timeline = useAppSelector((state) => selectTimelineByKey(state, key));

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!timeline && !!accountId) {
      dispatch(expandTimelineByKey({ key }));
    }
  }, [accountId, dispatch, key, timeline]);

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!timeline) {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  }

  return (
    <Column>
      <ColumnBackButton />
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountTimelineV2;
