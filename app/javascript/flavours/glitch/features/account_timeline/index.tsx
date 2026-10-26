import { useCallback, useEffect } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { useParams } from 'react-router';

import { List as ImmutableList } from 'immutable';

import {
  expandTimelineByKey,
  timelineKey,
} from '@/flavours/glitch/actions/timelines_typed';
import { AccountHeader } from '@/flavours/glitch/components/account_header';
import { Column } from '@/flavours/glitch/components/column';
import { ColumnHeader } from '@/flavours/glitch/components/column_header';
import { DisplayNameSimple } from '@/flavours/glitch/components/display_name/simple';
import { LimitedAccountHint } from '@/flavours/glitch/components/limited_account_hint';
import { LoadingIndicator } from '@/flavours/glitch/components/loading_indicator';
import { RemoteHint } from '@/flavours/glitch/components/remote_hint';
import StatusList from '@/flavours/glitch/components/status_list';
import { BundleColumnError } from '@/flavours/glitch/features/ui/components/bundle_column_error';
import { useAccount } from '@/flavours/glitch/hooks/useAccount';
import {
  useAccountId,
  useCurrentAccountId,
} from '@/flavours/glitch/hooks/useAccountId';
import { useAccountVisibility } from '@/flavours/glitch/hooks/useAccountVisibility';
import type { Account } from '@/flavours/glitch/models/account';
import { selectTimelineByKey } from '@/flavours/glitch/selectors/timelines';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';
import { isRedesignEnabled } from '@/flavours/glitch/utils/environment';

import { ProfileColumnHeader } from '../account/components/profile_column_header';

import { FeaturedTags } from './components/featured_tags';
import { AccountFilters } from './components/filters';
import { TagSuggestions } from './components/tags_suggestions';
import {
  AccountTimelineContext,
  useAccountContext,
  useAccountContextValue,
} from './hooks/useAccountContext';
import { usePinnedStatusIds } from './hooks/usePinned';
import classes from './styles.module.scss';

const emptyList = ImmutableList<string>();

const AccountTimeline: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const accountContext = useAccountContextValue(accountId);
  const account = useAccount(accountId);

  // Null means accountId does not exist (e.g. invalid acct). Undefined means loading.
  if (accountId === null) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  if (!accountId || !account) {
    return (
      <Column bindToDocument={!multiColumn}>
        <LoadingIndicator />
      </Column>
    );
  }

  // Add this key to remount the timeline when accountId changes.
  return (
    <AccountTimelineContext.Provider value={accountContext}>
      <InnerTimeline
        account={account}
        key={accountId}
        multiColumn={multiColumn}
      />
    </AccountTimelineContext.Provider>
  );
};

const InnerTimeline: FC<{ account: Account; multiColumn: boolean }> = ({
  account,
  multiColumn,
}) => {
  const accountId = account.id;
  const { tagged } = useParams<{ tagged?: string }>();
  const { boosts, replies } = useAccountContext();
  const key = timelineKey({
    type: 'account',
    userId: accountId,
    tagged,
    boosts,
    replies,
  });

  const timeline = useAppSelector((state) => selectTimelineByKey(state, key));
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const forceEmptyState = blockedBy || hidden || suspended;

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (accountId) {
      dispatch(expandTimelineByKey({ key }));
    }
  }, [accountId, dispatch, key]);

  const handleLoadMore = useCallback(
    (maxId: number) => {
      if (accountId) {
        dispatch(expandTimelineByKey({ key, maxId }));
      }
    },
    [accountId, dispatch, key],
  );

  const { isLoading: isPinnedLoading, statusIds: pinnedStatusIds } =
    usePinnedStatusIds({ accountId, tagged, forceEmptyState });

  const isLoading = !!timeline?.isLoading || isPinnedLoading;

  return (
    <Column bindToDocument={!multiColumn}>
      {isRedesignEnabled() ? (
        <ColumnHeader
          withBackButton
          title={<DisplayNameSimple account={account} />}
        />
      ) : (
        <ProfileColumnHeader multiColumn={multiColumn} />
      )}

      <StatusList
        alwaysPrepend
        prepend={<Prepend accountId={accountId} forceEmpty={forceEmptyState} />}
        append={<RemoteHint accountId={accountId} />}
        scrollKey='account_timeline'
        // We want to have this component when timeline is undefined (loading),
        // because if we don't the prepended component will re-render with every filter change.
        statusIds={forceEmptyState ? emptyList : (timeline?.items ?? emptyList)}
        featuredStatusIds={pinnedStatusIds}
        isLoading={isLoading}
        hasMore={!forceEmptyState && !!timeline?.hasMore}
        onLoadMore={handleLoadMore}
        emptyMessage={<EmptyMessage accountId={accountId} />}
        bindToDocument={!multiColumn}
        timelineId='account'
        withCounters
        className={classNames(classes.statusWrapper)}
      />
    </Column>
  );
};

const Prepend: FC<{
  accountId: string;
  forceEmpty: boolean;
}> = ({ forceEmpty, accountId }) => {
  const me = useCurrentAccountId();
  if (forceEmpty) {
    return <AccountHeader accountId={accountId} hideTabs />;
  }

  return (
    <>
      <AccountHeader accountId={accountId} hideTabs />
      <AccountFilters />
      <FeaturedTags accountId={accountId} />
      {me === accountId && <TagSuggestions />}
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
export default AccountTimeline;
