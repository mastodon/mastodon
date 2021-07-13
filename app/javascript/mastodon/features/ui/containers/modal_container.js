import { connect } from 'react-redux';
import { closeModal } from '../../../actions/modal';
import ModalRoot from '../components/modal_root';

const mapStateToProps = state => ({
  type: state.getIn(['modal', 0, 'modalType'], null),
  props: state.getIn(['modal', 0, 'modalProps'], {}),
});

const mapDispatchToProps = dispatch => ({
  onClose () {
    dispatch(closeModal());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ModalRoot);
