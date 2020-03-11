import { connect } from 'react-redux';
import IconWithBadge from 'mastodon/components/icon_with_badge';

const mapStateToProps = state => ({
  count: state.getIn(['notifications', 'unread']),
  id: 'bell',
});

export default connect(mapStateToProps)(IconWithBadge);
