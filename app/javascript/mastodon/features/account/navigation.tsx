import { useParams } from 'react-router-dom';

import { FeaturedTags } from 'mastodon/features/account/components/featured_tags';
import { normalizeForLookup } from 'mastodon/reducers/accounts_map';
import { useAppSelector } from 'mastodon/store';

export const AccountNavigation = () => {
  // TODO(trinitroglycerin): The 'tagged' property is recognized here and is used in a Route as well,
  // but it doesn't appear to be used in the FeaturedTags component in mainline
  const { acct } = useParams<{ acct: string; tagged: string }>();
  const { accountId, isLoading } = useAppSelector((state) => {
    const accountId = state.accounts_map.get(normalizeForLookup(acct)) ?? null;
    return {
      accountId,
      isLoading: accountId === null,
    };
  });

  if (isLoading || accountId === null) {
    return null;
  }

  return (
    <>
      <div className='flex-spacer' />
      <FeaturedTags accountId={accountId} />
    </>
  );
};
