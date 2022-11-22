import { connect } from 'react-redux';
import { isUserTouching } from 'flavours/glitch/is_mobile';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import Dropdown from '../components/dropdown';

const mapDispatchToProps = dispatch => ({
  isUserTouching,
  onModalOpen: props => dispatch(openModal('ACTIONS', props)),
  onModalClose: () => dispatch(closeModal()),
});

export default connect(null, mapDispatchToProps)(Dropdown);
