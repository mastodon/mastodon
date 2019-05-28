import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';
import { closeTutorial } from '../../../actions/tutorial';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  tutorial: state.getIn(['tutorial', 'visible']),
  isModalOpen: !!state.get('modal').modalType,
});

export default connect(mapStateToProps, null, null, { forwardRef: true })(ColumnsArea);
