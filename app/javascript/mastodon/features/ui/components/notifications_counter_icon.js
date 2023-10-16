import { connect } from 'react-redux';

import { ReactComponent as NotificationsIcon } from '@material-design-icons/svg/filled/notifications.svg';

import { IconWithBadge } from 'mastodon/components/icon_with_badge';


const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
  id: 'bell',
  icon: NotificationsIcon,
});

export default connect(mapStateToProps)(IconWithBadge);
