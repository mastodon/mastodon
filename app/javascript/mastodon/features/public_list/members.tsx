import { useState, useEffect } from 'react';

import { useParams } from 'react-router-dom';

import { importFetchedAccounts } from 'mastodon/actions/importer';
import { apiGetAccounts } from 'mastodon/api/lists';
import { Account } from 'mastodon/components/account';
import ScrollableList from 'mastodon/components/scrollable_list';
import { useAppDispatch } from 'mastodon/store';

export const Members: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const { id }: { id: string } = useParams();
  const [accountIds, setAccountIds] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const dispatch = useAppDispatch();

  useEffect(() => {
    setLoading(true);

    apiGetAccounts(id)
      .then((data) => {
        dispatch(importFetchedAccounts(data));
        setAccountIds(data.map((a) => a.id));
        setLoading(false);
        return '';
      })
      .catch(() => {
        setLoading(false);
      });
  }, [dispatch, id]);

  return (
    <ScrollableList
      scrollKey={`public_list/${id}/members`}
      trackScroll={!multiColumn}
      bindToDocument={!multiColumn}
      isLoading={loading}
      showLoading={loading && accountIds.length === 0}
      hasMore={false}
    >
      {accountIds.map((accountId) => (
        <Account key={accountId} id={accountId} withBio={false} />
      ))}
    </ScrollableList>
  );
};
