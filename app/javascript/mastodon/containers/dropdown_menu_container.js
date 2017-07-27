import { openModal, closeModal } from '../actions/modal';
import { connect } from 'react-redux';
import DropdownMenu from '../components/dropdown_menu';
import { isUserTouching } from '../is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
});

const mapDispatchToProps = dispatch => ({
  isUserTouching,
  onModalOpen: props => dispatch(openModal('ACTIONS', props)),
  onModalClose: () => dispatch(closeModal()),
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
