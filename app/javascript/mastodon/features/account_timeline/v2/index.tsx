import { useCallback, useEffect, useState } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useParams } from 'react-router';

import {
  expandTimelineByKey,
  timelineKey,
} from '@/mastodon/actions/timelines_typed';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { FeaturedCarousel } from '@/mastodon/components/featured_carousel';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { RemoteHint } from '@/mastodon/components/remote_hint';
import StatusList from '@/mastodon/components/status_list';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import { selectTimelineByKey } from '@/mastodon/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { AccountHeader } from '../components/account_header';
import { LimitedAccountHint } from '../components/limited_account_hint';

import { FilterContext } from './context';
import { AccountFilters } from './filters';

const AccountTimelineV2: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();

  const { tagged } = useParams<{ tagged?: string }>();
  const [boosts, setBoosts] = useState(false);
  const [replies, setReplies] = useState(false);
  const key = timelineKey({
    type: 'account',
    userId: accountId ?? '',
    tagged,
    boosts,
    replies,
  });

  const timeline = useAppSelector((state) => selectTimelineByKey(state, key));
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!timeline && !!accountId) {
      dispatch(expandTimelineByKey({ key }));
    }
  }, [accountId, dispatch, key, timeline]);

  const handleLoadMore = useCallback(
    (maxId: number) => {
      if (accountId) {
        dispatch(expandTimelineByKey({ key, maxId }));
      }
    },
    [accountId, dispatch, key],
  );

  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!timeline || !accountId) {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  }

  const forceEmptyState = blockedBy || hidden || suspended;

  return (
    <FilterContext.Provider value={{ boosts, setBoosts, replies, setReplies }}>
      <Column>
        <ColumnBackButton />

        <StatusList
          alwaysPrepend
          prepend={
            <Prepend
              accountId={accountId}
              tagged={tagged}
              forceEmpty={forceEmptyState}
            />
          }
          append={<RemoteHint accountId={accountId} />}
          scrollKey='account_timeline'
          statusIds={forceEmptyState ? [] : timeline.items}
          isLoading={timeline.isLoading}
          hasMore={!forceEmptyState && timeline.hasMore}
          onLoadMore={handleLoadMore}
          emptyMessage={<EmptyMessage accountId={accountId} />}
          bindToDocument={!multiColumn}
          timelineId='account'
          withCounters
        />
      </Column>
    </FilterContext.Provider>
  );
};

const Prepend: FC<{
  accountId: string;
  tagged?: string;
  forceEmpty: boolean;
}> = ({ forceEmpty, accountId, tagged }) => {
  if (forceEmpty) {
    return <AccountHeader accountId={accountId} hideTabs />;
  }

  return (
    <>
      <AccountHeader accountId={accountId} hideTabs />
      <AccountFilters />
      <FeaturedCarousel accountId={accountId} tagged={tagged} />
    </>
  );
};

const EmptyMessage: FC<{ accountId: string }> = ({ accountId }) => {
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  if (suspended) {
    return (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  } else if (hidden) {
    return <LimitedAccountHint accountId={accountId} />;
  } else if (blockedBy) {
    return (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  }

  return (
    <FormattedMessage
      id='empty_column.account_timeline'
      defaultMessage='No posts found'
    />
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountTimelineV2;
