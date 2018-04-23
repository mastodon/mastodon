import { openDropdownMenu, closeDropdownMenu } from 'flavours/glitch/actions/dropdown_menu';
import { openModal, closeModal } from 'flavours/glitch/actions/modal';
import { connect } from 'react-redux';
import DropdownMenu from 'flavours/glitch/components/dropdown_menu';
import { isUserTouching } from 'flavours/glitch/util/is_mobile';

const mapStateToProps = state => ({
  isModalOpen: state.get('modal').modalType === 'ACTIONS',
  dropdownPlacement: state.getIn(['dropdown_menu', 'placement']),
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
});

const mapDispatchToProps = (dispatch, { status, items }) => ({
  onOpen(id, onItemClick, dropdownPlacement) {
    dispatch(isUserTouching() ? openModal('ACTIONS', {
      status,
      actions: items.map(
        (item, i) => item ? {
          ...item,
          name: `${item.text}-${i}`,
          onClick: (e) => { return onItemClick(i, e) },
        } : null
      ),
    }) : openDropdownMenu(id, dropdownPlacement));
  },
  onClose(id) {
    dispatch(closeModal());
    dispatch(closeDropdownMenu(id));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
