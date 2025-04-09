import { useEffect } from 'react';

import type { Map as ImmutableMap } from 'immutable';
import { List as ImmutableList } from 'immutable';

import { fetchFeaturedTags } from 'mastodon/actions/featured_tags';
import { expandAccountFeaturedTimeline } from 'mastodon/actions/timelines';
import { ColumnBackButton } from 'mastodon/components/column_back_button';
import { RemoteHint } from 'mastodon/components/remote_hint';
import ScrollableList from 'mastodon/components/scrollable_list';
import StatusContainer from 'mastodon/containers/status_container';
import { useAccountId } from 'mastodon/hooks/useAccountId';
import { useAccountVisibility } from 'mastodon/hooks/useAccountVisibility';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { AccountHeader } from '../account_timeline/components/account_header';
import Column from '../ui/components/column';

import { EmptyMessage } from './components/empty_message';
import { FeaturedTag } from './components/featured_tag';

export type TagMap = ImmutableMap<
  'id' | 'name' | 'url' | 'statuses_count' | 'last_status_at' | 'accountId',
  string | null
>;

const AccountFeatured = () => {
  const accountId = useAccountId();
  const { suspended, blockedBy, hidden } = useAccountVisibility(accountId);
  const forceEmptyState = suspended || blockedBy || hidden;

  const dispatch = useAppDispatch();

  useEffect(() => {
    void dispatch(expandAccountFeaturedTimeline(accountId));
    dispatch(fetchFeaturedTags(accountId));
  }, [accountId, dispatch]);

  const account = useAppSelector(
    (state) => state.accounts.get(accountId ?? '') ?? null,
  );
  const isLoading = useAppSelector(
    (state) =>
      !accountId ||
      !!(state.timelines as ImmutableMap<string, unknown>).getIn([
        `account:${accountId}:pinned`,
        'isLoading',
      ]) ||
      !!state.user_lists.getIn(['featured_tags', accountId, 'isLoading']),
  );
  const featuredStatusIds = useAppSelector(
    (state) =>
      (state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned`, 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );
  const featuredTags = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['featured_tags', accountId, 'items'],
        ImmutableList(),
      ) as ImmutableList<TagMap>,
  );

  const hasMore = useAppSelector(
    (state) =>
      !!(state.timelines as ImmutableMap<string, unknown>).getIn(
        [`account:${accountId}:pinned`, 'hasMore'],
        false,
      ),
  );

  return (
    <Column>
      <ColumnBackButton />

      <ScrollableList
        prepend={
          accountId && (
            <AccountHeader accountId={accountId} hideTabs={forceEmptyState} />
          )
        }
        alwaysPrepend
        append={<RemoteHint accountId={accountId} />}
        scrollKey='account_featured'
        emptyMessage={
          <EmptyMessage
            blockedBy={blockedBy}
            hidden={hidden}
            suspended={suspended}
            accountId={accountId}
          />
        }
        timelineId='account'
        isLoading={isLoading}
        showLoading={isLoading}
        hasMore={hasMore}
      >
        {featuredTags.map((tag) => (
          <FeaturedTag
            key={tag.get('id')}
            tag={tag}
            account={account?.acct ?? ''}
          />
        ))}
        {featuredStatusIds.map((statusId) => (
          <StatusContainer
            key={`f-${statusId}`}
            // @ts-expect-error inferred props are wrong
            id={statusId}
            featured
            contextType='account'
          />
        ))}
      </ScrollableList>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default AccountFeatured;
