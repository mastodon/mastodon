import { connect } from 'react-redux';

import { openDropdownMenu, closeDropdownMenu } from 'mastodon/actions/dropdown_menu';
import { fetchHistory } from 'mastodon/actions/history';
import DropdownMenu from 'mastodon/components/dropdown_menu';

/**
 *
 * @param {import('mastodon/store').RootState} state
 * @param {*} props
 */
const mapStateToProps = (state, { statusId }) => ({
  openDropdownId: state.dropdownMenu.openId,
  openedViaKeyboard: state.dropdownMenu.keyboard,
  items: state.getIn(['history', statusId, 'items']),
  loading: state.getIn(['history', statusId, 'loading']),
});

const mapDispatchToProps = (dispatch, { statusId }) => ({

  onOpen (id, onItemClick, keyboard) {
    dispatch(fetchHistory(statusId));
    dispatch(openDropdownMenu({ id, keyboard }));
  },

  onClose (id) {
    dispatch(closeDropdownMenu({ id }));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(DropdownMenu);
