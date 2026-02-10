import { useEffect } from 'react';
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
import { TimelineHint } from '@/mastodon/components/timeline_hint';
import BundleColumnError from '@/mastodon/features/ui/components/bundle_column_error';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useAccountVisibility } from '@/mastodon/hooks/useAccountVisibility';
import type { Account as AccountType } from '@/mastodon/models/account';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';
import { LimitedAccountHint } from '../account_timeline/components/limited_account_hint';

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
          <EmptyMessage
            account={account}
            followerIds={followerList?.items ?? ImmutableList<string>()}
          />
        }
        bindToDocument={!multiColumn}
      >
        {!forceEmptyState &&
          followerList?.items.map((followerId) => (
            <Account key={followerId} id={followerId} />
          ))}
      </ScrollableList>
    </Column>
  );
};

const RemoteHint: FC<{ domain?: string; url: string }> = ({ domain, url }) => {
  if (!domain) {
    return null;
  }
  return (
    <TimelineHint
      url={url}
      message={
        <FormattedMessage
          id='hints.profiles.followers_may_be_missing'
          defaultMessage='Followers for this profile may be missing.'
        />
      }
      label={
        <FormattedMessage
          id='hints.profiles.see_more_followers'
          defaultMessage='See more followers on {domain}'
          values={{ domain: <strong>{domain}</strong> }}
        />
      }
    />
  );
};

const EmptyMessage: FC<{
  account: AccountType;
  followerIds: ImmutableList<string>;
}> = ({ account, followerIds }) => {
  const { blockedBy, hidden, suspended } = useAccountVisibility(account.id);

  if (suspended) {
    return (
      <FormattedMessage
        id='empty_column.account_suspended'
        defaultMessage='Account suspended'
      />
    );
  }

  if (hidden) {
    return <LimitedAccountHint accountId={account.id} />;
  }

  if (blockedBy) {
    return (
      <FormattedMessage
        id='empty_column.account_unavailable'
        defaultMessage='Profile unavailable'
      />
    );
  }

  if (account.hide_collections && followerIds.isEmpty()) {
    return (
      <FormattedMessage
        id='empty_column.account_hides_collections'
        defaultMessage='This user has chosen to not make this information available'
      />
    );
  }

  const domain = account.acct.split('@')[1];
  if (domain && followerIds.isEmpty()) {
    return <RemoteHint domain={domain} url={account.url} />;
  }

  return (
    <FormattedMessage
      id='account.followers.empty'
      defaultMessage='No one follows this user yet.'
    />
  );
};

// eslint-disable-next-line import/no-default-export -- Used by async components.
export default Followers;
