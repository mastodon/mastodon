import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  swipeToChangeColumns: state.getIn(['local_settings', 'swipe_to_change_columns']),
});

export default connect(mapStateToProps, null, null, { forwardRef: true })(ColumnsArea);
