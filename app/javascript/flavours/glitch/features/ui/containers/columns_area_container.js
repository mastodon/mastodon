import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';
import { openModal } from 'flavours/glitch/actions/modal';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  swipeToChangeColumns: state.getIn(['local_settings', 'swipe_to_change_columns']),
});

const mapDispatchToProps = dispatch => ({
  openSettings (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal('SETTINGS', {}));
  },
});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(ColumnsArea);
