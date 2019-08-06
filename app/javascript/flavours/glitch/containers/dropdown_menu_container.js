import { openDropdownMenu, closeDropdownMenu } from 'flavours/glitch/actions/dropdown_menu';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import { connect } from 'react-redux';
import DropdownMenu from 'flavours/glitch/components/dropdown_menu';
import { isUserTouching } from 'flavours/glitch/util/is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
  dropdownPlacement: state.getIn(['dropdown_menu', 'placement']),
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
  openedViaKeyboard: state.getIn(['dropdown_menu', 'keyboard']),
});

const mapDispatchToProps = (dispatch, { status, items }) => ({
  onOpen(id, onItemClick, dropdownPlacement, keyboard) {
    dispatch(isUserTouching() ? openModal('ACTIONS', {
      status,
      actions: items.map(
        (item, i) => item ? {
          ...item,
          name: `${item.text}-${i}`,
          onClick: item.action ? ((e) => { return onItemClick(i, e) }) : null,
        } : null
      ),
    }) : openDropdownMenu(id, dropdownPlacement, keyboard));
  },
  onClose(id) {
    dispatch(closeModal('ACTIONS'));
    dispatch(closeDropdownMenu(id));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
