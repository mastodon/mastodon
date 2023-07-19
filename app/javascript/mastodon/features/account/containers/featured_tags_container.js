import { List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { makeGetAccount } from 'mastodon/selectors';

import FeaturedTags from '../components/featured_tags';

const mapStateToProps = () => {
  const getAccount = makeGetAccount();

  return (state, { accountId }) => ({
    account: getAccount(state, accountId),
    featuredTags: state.getIn(['user_lists', 'featured_tags', accountId, 'items'], ImmutableList()),
  });
};

export default connect(mapStateToProps)(FeaturedTags);
