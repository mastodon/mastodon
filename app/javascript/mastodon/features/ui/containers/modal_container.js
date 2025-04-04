import { List as ImmutableList } from 'immutable';
import { connect } from 'react-redux';

import { openModal, closeModal } from '../../../actions/modal';
import ModalRoot from '../components/modal_root';

const mapStateToProps = state => ({
  ignoreFocus: state.getIn(['modal', 'ignoreFocus']),
  modals: state.getIn(['modal', 'stack'], ImmutableList()),
});

const mapDispatchToProps = dispatch => ({
  onClose (confirmationMessage, ignoreFocus = false) {
    if (confirmationMessage) {
      dispatch(
        openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: confirmationMessage.message,
            confirm: confirmationMessage.confirm,
            onConfirm: () => dispatch(closeModal({
              modalType: undefined,
              ignoreFocus: { ignoreFocus },
            })),
          },
        }),
      );
    } else {
      dispatch(closeModal({
        modalType: undefined,
        ignoreFocus: { ignoreFocus },
      }));
    }
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(ModalRoot);
