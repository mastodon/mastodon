import { connect } from 'react-redux';

import { changeComposeVisibility } from 'flavours/glitch/actions/compose';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import { isUserTouching } from 'flavours/glitch/is_mobile';

import PrivacyDropdown from '../components/privacy_dropdown';

const mapStateToProps = state => ({
  value: state.getIn(['compose', 'privacy']),
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeComposeVisibility(value));
  },

  isUserTouching,
  onModalOpen: props => dispatch(openModal({
    modalType: 'ACTIONS',
    modalProps: props,
  })),
  onModalClose: () => dispatch(closeModal({
    modalType: undefined,
    ignoreFocus: false,
  })),

});

export default connect(mapStateToProps, mapDispatchToProps)(PrivacyDropdown);
