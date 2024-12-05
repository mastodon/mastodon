import { connect } from 'react-redux';

import { fetchRelationships } from 'mastodon/actions/accounts';

import { openDropdownMenu, closeDropdownMenu } from '../actions/dropdown_menu';
import { openModal, closeModal } from '../actions/modal';
import DropdownMenu from '../components/dropdown_menu';
import { isUserTouching } from '../is_mobile';

/**
 * @param {import('mastodon/store').RootState} state
 */
const mapStateToProps = state => ({
  openDropdownId: state.dropdownMenu.openId,
  openedViaKeyboard: state.dropdownMenu.keyboard,
});

const mapDispatchToProps = (dispatch, { status, items, scrollKey }) => ({
  onOpen(id, onItemClick, keyboard) {
    if (status) {
      dispatch(fetchRelationships([status.getIn(['account', 'id'])]));
    }

    dispatch(isUserTouching() ? openModal({
      modalType: 'ACTIONS',
      modalProps: {
        status,
        actions: items,
        onClick: onItemClick,
      },
    }) : openDropdownMenu({ id, keyboard, scrollKey }));
  },

  onClose(id) {
    dispatch(closeModal({
      modalType: 'ACTIONS',
      ignoreFocus: false,
    }));
    dispatch(closeDropdownMenu({ id }));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
