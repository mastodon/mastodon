import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';
import { openModal } from 'flavours/glitch/actions/modal';

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
});

const mapDispatchToProps = dispatch => ({
  openSettings (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal('SETTINGS', {}));
  },
});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(ColumnsArea);
