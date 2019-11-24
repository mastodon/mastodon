import { openDropdownMenu, closeDropdownMenu } from '../actions/dropdown_menu';
import { fetchRelationships } from 'mastodon/actions/accounts';
import { openModal, closeModal } from '../actions/modal';
import { connect } from 'react-redux';
import DropdownMenu from '../components/dropdown_menu';
import { isUserTouching } from '../is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
  dropdownPlacement: state.getIn(['dropdown_menu', 'placement']),
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
  openedViaKeyboard: state.getIn(['dropdown_menu', 'keyboard']),
});

const mapDispatchToProps = (dispatch, { status, items }) => ({
  onOpen(id, onItemClick, dropdownPlacement, keyboard) {
    if (status) {
      dispatch(fetchRelationships([status.getIn(['account', 'id'])]));
    }

    dispatch(isUserTouching() ? openModal('ACTIONS', {
      status,
      actions: items,
      onClick: onItemClick,
    }) : openDropdownMenu(id, dropdownPlacement, keyboard));
  },

  onClose(id) {
    dispatch(closeModal('ACTIONS'));
    dispatch(closeDropdownMenu(id));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
