import { connect } from 'react-redux';

import NotificationsIcon from '@material-symbols/svg-600/outlined/notifications-fill.svg?react';

import { IconWithBadge } from 'mastodon/components/icon_with_badge';


const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
  id: 'bell',
  icon: NotificationsIcon,
});

export default connect(mapStateToProps)(IconWithBadge);
