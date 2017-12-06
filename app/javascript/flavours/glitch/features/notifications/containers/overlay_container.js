//  Package imports.
import { connect } from 'react-redux';

//  Our imports.
import NotificationOverlay from '../components/overlay';
import { markNotificationForDelete } from 'flavours/glitch/actions/notifications';

const mapDispatchToProps = dispatch => ({
  onMarkForDelete(id, yes) {
    dispatch(markNotificationForDelete(id, yes));
  },
});

const mapStateToProps = state => ({
  show: state.getIn(['notifications', 'cleaningMode']),
});

export default connect(mapStateToProps, mapDispatchToProps)(NotificationOverlay);
