import { connect } from 'react-redux';
import IconWithBadge from 'flavours/glitch/components/icon';

const mapStateToProps = state => ({
  count: state.getIn(['local_settings', 'notifications', 'tab_badge']) ? state.getIn(['notifications', 'unread']) : 0,
  icon: 'bell',
});

export default connect(mapStateToProps)(IconWithBadge);
