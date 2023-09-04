import { connect } from 'react-redux';

import { openDropdownMenu, closeDropdownMenu } from 'flavours/glitch/actions/dropdown_menu';
import { fetchHistory } from 'flavours/glitch/actions/history';
import DropdownMenu from 'flavours/glitch/components/dropdown_menu';

const mapStateToProps = (state, { statusId }) => ({
  openDropdownId: state.getIn(['dropdown_menu', 'openId']),
  openedViaKeyboard: state.getIn(['dropdown_menu', 'keyboard']),
  items: state.getIn(['history', statusId, 'items']),
  loading: state.getIn(['history', statusId, 'loading']),
});

const mapDispatchToProps = (dispatch, { statusId }) => ({

  onOpen (id, onItemClick, keyboard) {
    dispatch(fetchHistory(statusId));
    dispatch(openDropdownMenu(id, keyboard));
  },

  onClose (id) {
    dispatch(closeDropdownMenu(id));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
