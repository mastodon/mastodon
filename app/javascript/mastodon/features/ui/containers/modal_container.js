import { connect } from 'react-redux';
import { openModal, closeModal } from '../../../actions/modal';
import ModalRoot from '../components/modal_root';

const mapStateToProps = state => ({
  ignoreFocus: state.getIn(['modal', 'ignoreFocus']),
  type: state.getIn(['modal', 'stack', 0, 'modalType'], null),
  props: state.getIn(['modal', 'stack', 0, 'modalProps'], {}),
});

const mapDispatchToProps = dispatch => ({
  onClose (confirmationMessage, ignoreFocus = false) {
    if (confirmationMessage) {
      dispatch(
        openModal('CONFIRM', {
          message: confirmationMessage.message,
          confirm: confirmationMessage.confirm,
          onConfirm: () => dispatch(closeModal(undefined, { ignoreFocus })),
        }),
      );
    } else {
      dispatch(closeModal(undefined, { ignoreFocus }));
    }
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ModalRoot);
