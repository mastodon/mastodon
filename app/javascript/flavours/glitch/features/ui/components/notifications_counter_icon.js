import { connect } from 'react-redux';

import NotificationsIcon from '@/material-icons/400-24px/notifications-fill.svg?react';
import { IconWithBadge } from 'flavours/glitch/components/icon_with_badge';

const mapStateToProps = state => ({
  count: state.getIn(['local_settings', 'notifications', 'tab_badge']) ? state.getIn(['notifications', 'unread']) : 0,
  id: 'bell',
  icon: NotificationsIcon,
});

export default connect(mapStateToProps)(IconWithBadge);
