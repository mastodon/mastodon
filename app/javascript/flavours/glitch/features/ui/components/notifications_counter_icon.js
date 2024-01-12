import { connect } from 'react-redux';

import { IconWithBadge } from 'flavours/glitch/components/icon_with_badge';
import NotificationsIcon from 'mastodon/../material-icons/400-24px/notifications-fill.svg?react';

const mapStateToProps = state => ({
  count: state.getIn(['local_settings', 'notifications', 'tab_badge']) ? state.getIn(['notifications', 'unread']) : 0,
  id: 'bell',
  icon: NotificationsIcon,
});

export default connect(mapStateToProps)(IconWithBadge);
