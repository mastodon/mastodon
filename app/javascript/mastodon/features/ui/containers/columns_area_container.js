import { connect } from 'react-redux';
import ColumnsArea from '../components/columns_area';

const mapStateToProps = state => ({
  columns: state.settings.get('columns'),
  isModalOpen: !!state.modal.modalType,
});

export default connect(mapStateToProps, null, null, { withRef: true })(ColumnsArea);
