import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';
import { closeTutorial } from '../../../actions/tutorial';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  tutorial: state.getIn(['tutorial', 'visible']),
});

const mapDispatchToProps = dispatch => ({
  closeTutorial() {
    dispatch(closeTutorial());
  },
});

export default connect(mapStateToProps, mapDispatchToProps, null, { withRef: true })(ColumnsArea);
