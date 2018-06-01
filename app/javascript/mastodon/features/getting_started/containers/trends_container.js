import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import { fetchTrends } from '../../../actions/trends';
import Trends from '../components/trends';

const mapStateToProps = state => ({
  trends: state.getIn(['trends', 'items']),
  loading: state.getIn(['trends', 'isLoading']),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrends()),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Trends));
