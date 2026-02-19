import { useEffect } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useDebouncedCallback } from 'use-debounce';

import { expandFollowing, fetchFollowing } from '@/mastodon/actions/accounts';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import { selectUserListWithoutMe } from '@/mastodon/selectors/user_lists';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { EmptyMessageProps } from '../followers/components/empty';
import { BaseEmptyMessage } from '../followers/components/empty';
import { AccountList } from '../followers/components/list';

import { RemoteHint } from './components/remote';

const Followers: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const currentAccountId = useAppSelector(
    (state) => (state.meta.get('me') as string | null) ?? null,
  );
  const followingList = useAppSelector((state) =>
    selectUserListWithoutMe(state, 'following', accountId),
  );

  const dispatch = useAppDispatch();
  useEffect(() => {
    if (!followingList && accountId) {
      dispatch(fetchFollowing(accountId));
    }
  }, [accountId, dispatch, followingList]);

  const loadMore = useDebouncedCallback(
    () => {
      if (accountId) {
        dispatch(expandFollowing(accountId));
      }
    },
    300,
    { leading: true },
  );

  const relationship = useRelationship(accountId);

  const followedId = relationship?.followed_by ? currentAccountId : null;
  const followingExceptMeHidden = !!(
    account?.hide_collections &&
    followingList?.items.length === 0 &&
    followedId
  );

  const footer = followingExceptMeHidden && (
    <div className='empty-column-indicator'>
      <FormattedMessage
        id='following.hide_other_following'
        defaultMessage='This user has chosen to not make the rest of who they follow visible'
      />
    </div>
  );

  const domain = account?.acct.split('@')[1];
  return (
    <AccountList
      accountId={accountId}
      append={domain && <RemoteHint domain={domain} url={account.url} />}
      emptyMessage={<EmptyMessage account={account} />}
      footer={footer}
      list={followingList}
      loadMore={loadMore}
      prependAccountId={followedId}
      scrollKey='following'
    />
  );
};

const EmptyMessage: FC<EmptyMessageProps> = (props) => (
  <BaseEmptyMessage
    {...props}
    defaultMessage={
      <FormattedMessage
        id='account.follows.empty'
        defaultMessage="This user doesn't follow anyone yet."
      />
    }
  />
);

// eslint-disable-next-line import/no-default-export -- Used by async components.
export default Followers;
