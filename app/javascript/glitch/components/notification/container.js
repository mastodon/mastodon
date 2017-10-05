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

//  Our imports  //
import Notification from '.';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const mapStateToProps = (state, props) => {
  // replace account id with object
  let leNotif = props.notification.set('account', state.getIn(['accounts', props.notification.get('account')]));

  // populate markedForDelete from state - is mysteriously lost somewhere
  for (let n of state.getIn(['notifications', 'items'])) {
    if (n.get('id') === props.notification.get('id')) {
      leNotif = leNotif.set('markedForDelete', n.get('markedForDelete'));
      break;
    }
  }

  return ({
    notification: leNotif,
    settings: state.get('local_settings'),
    notifCleaning: state.getIn(['notifications', 'cleaningMode']),
  });
};

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

export default connect(mapStateToProps)(Notification);
