import { useEffect, useMemo } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

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
import { useRelationship } from '@/mastodon/hooks/useRelationship';
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

    // Returns the list of followers except the current account.
    return {
      items: (
        list.get('items', ImmutableList<string>()) as ImmutableList<string>
      )
        .filter((id) => id !== currentAccountId)
        .toArray(),
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

  const relationship = useRelationship(accountId);
  const { blockedBy, hidden, suspended } = useAccountVisibility(accountId);

  const forceEmptyState = blockedBy || hidden || suspended;
  const domain = account?.acct.split('@')[1];

  // Determine children, prepending the current account if they are followed.
  const isFollower = currentAccountId !== null && !!relationship?.following;
  const followersExceptMeHidden = !!(
    account?.hide_collections &&
    followerList?.items.length === 0 &&
    isFollower
  );
  const children = useMemo(() => {
    if (forceEmptyState || !followerList) {
      return [];
    }
    const children = followerList.items.map((followerId) => (
      <Account key={followerId} id={followerId} />
    ));

    if (isFollower) {
      children.unshift(
        <Account key={currentAccountId} id={currentAccountId} minimal />,
      );
    }
    return children;
  }, [currentAccountId, followerList, isFollower, forceEmptyState]);

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
        footer={
          followersExceptMeHidden && (
            <div className='empty-column-indicator'>
              <FormattedMessage
                id='followers.hide_other_followers'
                defaultMessage='This user has chosen to not make their other followers visible'
              />
            </div>
          )
        }
      >
        {children}
      </ScrollableList>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export -- Used by async components.
export default Followers;
