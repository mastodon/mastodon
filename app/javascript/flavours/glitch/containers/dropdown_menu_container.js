import { connect } from 'react-redux';

import { openDropdownMenu, closeDropdownMenu } from 'flavours/glitch/actions/dropdown_menu';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import DropdownMenu from 'flavours/glitch/components/dropdown_menu';

import { isUserTouching } from '../is_mobile';

const mapStateToProps = state => ({
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
  openedViaKeyboard: state.getIn(['dropdown_menu', 'keyboard']),
});

const mapDispatchToProps = (dispatch, { status, items, scrollKey }) => ({
  onOpen(id, onItemClick, keyboard) {
    dispatch(isUserTouching() ? openModal({
      modalType: 'ACTIONS',
      modalProps: {
        status,
        actions: items,
        onClick: onItemClick,
      },
    }) : openDropdownMenu(id, keyboard, scrollKey));
  },

  onClose(id) {
    dispatch(closeModal({
      modalType: 'ACTIONS',
      ignoreFocus: false,
    }));
    dispatch(closeDropdownMenu(id));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
