import { connect } from 'react-redux';
import IconWithBadge from 'flavours/glitch/components/icon_with_badge';

const mapStateToProps = state => ({
  count: state.getIn(['local_settings', 'notifications', 'tab_badge']) ? state.getIn(['notifications', 'unread']) : 0,
  issueBadge: state.getIn(['settings', 'notifications', 'alerts']).includes(true) && state.getIn(['notifications', 'browserSupport']) && state.getIn(['notifications', 'browserPermission']) !== 'granted',
  id: 'bell',
});

export default connect(mapStateToProps)(IconWithBadge);
