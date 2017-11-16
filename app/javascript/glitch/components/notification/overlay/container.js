/*

`<NotificationOverlayContainer>`
=========================

This container connects `<NotificationOverlay>`s to the Redux store.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import { connect } from 'react-redux';

//  Our imports  //
import NotificationOverlay from './notification_overlay';
import { markNotificationForDelete } from '../../../../mastodon/actions/notifications';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Dispatch mapping:
-----------------

The `mapDispatchToProps()` function maps dispatches to our store to the
various props of our component. We only need to provide a dispatch for
deleting notifications.

*/

const mapDispatchToProps = dispatch => ({
  onMarkForDelete(id, yes) {
    dispatch(markNotificationForDelete(id, yes));
  },
});

const mapStateToProps = state => ({
  show: state.getIn(['notifications', 'cleaningMode']),
});

export default connect(mapStateToProps, mapDispatchToProps)(NotificationOverlay);
