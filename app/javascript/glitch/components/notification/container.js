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

export default connect(makeMapStateToProps)(Notification);
