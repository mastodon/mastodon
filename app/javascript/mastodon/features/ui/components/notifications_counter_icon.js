import { connect } from 'react-redux';
import IconWithBadge from 'mastodon/components/icon_with_badge';

const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
  issueBadge: state.getIn(['settings', 'notifications', 'alerts']).includes(true) && state.getIn(['notifications', 'browserSupport']) && state.getIn(['notifications', 'browserPermission']) !== 'granted',
  id: 'bell',
});

export default connect(mapStateToProps)(IconWithBadge);
