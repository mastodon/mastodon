import { connect } from 'react-redux';
import FeaturedTags from '../components/featured_tags';
import { makeGetAccount } from 'mastodon/selectors';
import { List as ImmutableList } from 'immutable';

const mapStateToProps = () => {
  const getAccount = makeGetAccount();

  return (state, { accountId }) => ({
    account: getAccount(state, accountId),
    featuredTags: state.getIn(['user_lists', 'featured_tags', accountId, 'items'], ImmutableList()),
  });
};

export default connect(mapStateToProps)(FeaturedTags);
