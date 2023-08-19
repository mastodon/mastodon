import { List as ImmutableList } from 'immutable';

import { getAccount } from 'mastodon/selectors/accounts';
import { useAppSelector } from 'mastodon/store';

import FeaturedTags from '../components/featured_tags';

interface Props {
  accountId: string;
}

const FeaturedTagsContainer = ({ accountId }: Props) => {
  const account = useAppSelector((state) => getAccount(state, accountId));
  const featuredTags = useAppSelector((state) => {
    return state.user_lists.getIn(
      ['featured_tags', accountId, 'items'],
      ImmutableList()
    );
  });

  return <FeaturedTags account={account} featuredTags={featuredTags} />;
};

export { FeaturedTagsContainer as FeaturedTags };
