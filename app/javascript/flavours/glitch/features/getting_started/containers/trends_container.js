import { connect } from 'react-redux';
import { fetchTrends } from 'mastodon/actions/trends';
import Trends from '../components/trends';

const mapStateToProps = state => ({
  trends: state.getIn(['trends', 'items']),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrends()),
});

export default connect(mapStateToProps, mapDispatchToProps)(Trends);
