import { openDropdownMenu, closeDropdownMenu } from '../actions/dropdown_menu';
import { openModal, closeModal } from '../actions/modal';
import { connect } from 'react-redux';
import DropdownMenu from '../components/dropdown_menu';
import { isUserTouching } from '../is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
  dropdownPlacement: state.getIn(['dropdown_menu', 'placement']),
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
});

const mapDispatchToProps = (dispatch, { status, items }) => ({
  onOpen(id, onItemClick, dropdownPlacement) {
    dispatch(isUserTouching() ? openModal('ACTIONS', {
      status,
      actions: items,
      onClick: onItemClick,
    }) : openDropdownMenu(id, dropdownPlacement));
  },
  onClose(id) {
    dispatch(closeModal());
    dispatch(closeDropdownMenu(id));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
