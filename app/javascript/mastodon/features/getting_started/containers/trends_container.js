import { connect } from 'react-redux';

import { fetchTrendingHashtags } from 'mastodon/actions/trends';

import Trends from '../components/trends';

const mapStateToProps = state => ({
  trends: state.getIn(['trends', 'tags', 'items']),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrendingHashtags()),
});

export default connect(mapStateToProps, mapDispatchToProps)(Trends);
