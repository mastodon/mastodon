import { connect } from 'react-redux';
import { closeModal } from '../../../actions/modal';
import ModalRoot from '../components/modal_root';

const mapStateToProps = state => ({
  type: state.get('modal').modalType,
  props: state.get('modal').modalProps,
});

const mapDispatchToProps = dispatch => ({
  onClose () {
    dispatch(closeModal());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ModalRoot);
