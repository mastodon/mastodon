import React from 'react';
import ComposeFormContainer from '../../compose/containers/compose_form_container';
import NotificationsContainer from '../../ui/containers/notifications_container';
import LoadingBarContainer from '../../ui/containers/loading_bar_container';

export default class Compose extends React.PureComponent {

  render () {
    return (
      <div>
        <ComposeFormContainer />
        <NotificationsContainer />
        <LoadingBarContainer className='loading-bar' />
      </div>
    );
  }

}
