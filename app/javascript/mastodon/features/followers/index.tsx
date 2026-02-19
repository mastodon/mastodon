import { useEffect } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { useDebouncedCallback } from 'use-debounce';

import { expandFollowers, fetchFollowers } from '@/mastodon/actions/accounts';
import { useAccount } from '@/mastodon/hooks/useAccount';
import { useAccountId } from '@/mastodon/hooks/useAccountId';
import { useRelationship } from '@/mastodon/hooks/useRelationship';
import { selectUserListWithoutMe } from '@/mastodon/selectors/user_lists';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { EmptyMessageProps } from './components/empty';
import { BaseEmptyMessage } from './components/empty';
import { AccountList } from './components/list';

const Followers: FC = () => {
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const currentAccountId = useAppSelector(
    (state) => (state.meta.get('me') as string | null) ?? null,
  );
  const followerList = useAppSelector((state) =>
    selectUserListWithoutMe(state, 'followers', accountId),
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

  const followerId = relationship?.following ? currentAccountId : null;
  const followersExceptMeHidden = !!(
    account?.hide_collections &&
    followerList?.items.length === 0 &&
    followerId
  );

  const footer = followersExceptMeHidden && (
    <div className='empty-column-indicator'>
      <FormattedMessage
        id='followers.hide_other_followers'
        defaultMessage='This user has chosen to not make their other followers visible'
      />
    </div>
  );

  return (
    <AccountList
      accountId={accountId}
      footer={footer}
      emptyMessage={<EmptyMessage account={account} />}
      list={followerList}
      loadMore={loadMore}
      prependAccountId={followerId}
      scrollKey='followers'
    />
  );
};

const EmptyMessage: FC<EmptyMessageProps> = (props) => (
  <BaseEmptyMessage
    {...props}
    defaultMessage={
      <FormattedMessage
        id='account.followers.empty'
        defaultMessage='No one follows this user yet.'
      />
    }
  />
);

// eslint-disable-next-line import/no-default-export -- Used by async components.
export default Followers;
