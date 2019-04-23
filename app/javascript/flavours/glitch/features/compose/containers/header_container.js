import { openModal } from 'flavours/glitch/actions/modal';
import { connect }   from 'react-redux';
import Header from '../components/header';

const mapStateToProps = state => {
  return {
    columns: state.getIn(['settings', 'columns']),
    unreadNotifications: state.getIn(['notifications', 'unread']),
    showNotificationsBadge: state.getIn(['local_settings', 'notifications', 'tab_badge']),
  };
};

const mapDispatchToProps = (dispatch, { intl }) => ({
  onSettingsClick (e) {
    e.preventDefault();
    e.stopPropagation();
    dispatch(openModal('SETTINGS', {}));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Header);
