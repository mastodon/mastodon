/*

`<NotificationContainer>`
=========================

This container connects `<Notification>`s to the Redux store.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { makeGetNotification } from '../../../mastodon/selectors';

//  Our imports  //
import Notification from '.';
import { deleteNotification } from '../../../mastodon/actions/notifications';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

State mapping:
--------------

The `mapStateToProps()` function maps various state properties to the
props of our component. We wrap this in `makeMapStateToProps()` so that
we only have to call `makeGetNotification()` once instead of every
time.

*/

const makeMapStateToProps = () => {
  const getNotification = makeGetNotification();

  const mapStateToProps = (state, props) => ({
    notification: getNotification(state, props.notification, props.accountId),
    settings: state.get('local_settings'),
  });

  return mapStateToProps;
};

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Dispatch mapping:
-----------------

The `mapDispatchToProps()` function maps dispatches to our store to the
various props of our component. We only need to provide a dispatch for
deleting notifications.

*/

const mapDispatchToProps = dispatch => ({
  onDeleteNotification (id) {
    dispatch(deleteNotification(id));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(Notification);
