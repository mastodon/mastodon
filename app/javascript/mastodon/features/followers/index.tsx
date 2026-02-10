import { useEffect } from 'react';
import type { FC } from 'react';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { useDebouncedCallback } from 'use-debounce';

import { expandFollowers, fetchFollowers } from '@/mastodon/actions/accounts';
import { Account } from '@/mastodon/components/account';
import { Column } from '@/mastodon/components/column';
import { ColumnBackButton } from '@/mastodon/components/column_back_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import ScrollableList from '@/mastodon/components/scrollable_list';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';

import { EmptyMessage } from './components/empty';
import { RemoteHint } from './components/remote';

const selectFollowerList = createAppSelector(
  [
    (state) => state.user_lists,
    (state) => (state.meta.get('me') as string | null) ?? null,
    (_state, accountId?: string | null) => accountId ?? null,
  ],
  (lists, currentAccountId, accountId) => {
    if (!accountId) {
      return null;
    }
    const list = lists.getIn(['followers', accountId]) as
      | ImmutableMap<string, unknown>
      | undefined;
    if (!list) {
      return null;
    }

    // Gets the items, sorting the current account first.
    let items = list.get(
      'items',
      ImmutableList<string>(),
    ) as ImmutableList<string>;
    if (currentAccountId && items.includes(currentAccountId)) {
      items = ImmutableList([currentAccountId]).concat(
        items.filter((id) => id !== currentAccountId),
      );
    }

    return {
      items,
      isLoading: !!list.get('isLoading', true),
      hasMore: !!list.get('hasMore', false),
    };
  },
);

const Followers: FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const currentAccountId = useAppSelector(
    (state) => (state.meta.get('me') as string | null) ?? null,
  );
  const followerList = useAppSelector((state) =>
    selectFollowerList(state, accountId),
  );

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!followerList && accountId) {
      dispatch(fetchFollowers(accountId));
    }
  }, [accountId, dispatch, followerList]);

  const loadMore = useDebouncedCallback(
    () => {
      if (accountId) {
        dispatch(expandFollowers(accountId));
      }
    },
    300,
    { leading: true },
  );

  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);
  const forceEmptyState = blockedBy || hidden || suspended;

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

  const domain = account.acct.split('@')[1];

  return (
    <Column>
      <ColumnBackButton />

      <ScrollableList
        scrollKey='followers'
        hasMore={!forceEmptyState && followerList?.hasMore}
        isLoading={followerList?.isLoading ?? true}
        onLoadMore={loadMore}
        prepend={<AccountHeader accountId={accountId} hideTabs />}
        alwaysPrepend
        append={<RemoteHint domain={domain} url={account.url} />}
        emptyMessage={
          <EmptyMessage account={account} followerIds={followerList?.items} />
        }
        bindToDocument={!multiColumn}
      >
        {!forceEmptyState &&
          followerList?.items.map((followerId) => (
            <Account
              key={followerId}
              id={followerId}
              minimal={followerId === currentAccountId}
            />
          ))}
      </ScrollableList>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export -- Used by async components.
export default Followers;
