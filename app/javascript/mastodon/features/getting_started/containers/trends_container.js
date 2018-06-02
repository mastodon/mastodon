import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import { fetchTrends } from '../../../actions/trends';
import Trends from '../components/trends';
import { changeSetting } from '../../../actions/settings';

const mapStateToProps = state => ({
  trends: state.getIn(['trends', 'items']),
  loading: state.getIn(['trends', 'isLoading']),
  showTrends: state.getIn(['settings', 'trends', 'show']),
});

const mapDispatchToProps = dispatch => ({
  fetchTrends: () => dispatch(fetchTrends()),
  toggleTrends: show => dispatch(changeSetting(['trends', 'show'], show)),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Trends));
