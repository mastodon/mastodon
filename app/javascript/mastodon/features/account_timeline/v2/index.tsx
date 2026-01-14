import type { FC } from 'react';

import type { Map as ImmutableMap } from 'immutable';

import { timelineKey } from '@/mastodon/actions/timelines_typed';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { createAppSelector, useAppSelector } from '@/mastodon/store';

interface TimelineState {
  unread: number;
  online: boolean;
  top: boolean;
  isLoading: boolean;
  hasMore: boolean;
  pendingItems: string[];
  items: string[];
}

const selectTimeline = createAppSelector(
  [
    (_, key: string) => key,
    (state) =>
      state.timelines as ImmutableMap<string, ImmutableMap<string, unknown>>,
  ],
  (key, timelines) => {
    return timelines.get(key)?.toJSON() as TimelineState | undefined;
  },
);

const AccountTimelineV2: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const key = timelineKey({ type: 'account', userId: accountId ?? '' });
  const timeline = useAppSelector((state) => selectTimeline(state, key));

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
