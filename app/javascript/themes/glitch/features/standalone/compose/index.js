import React from 'react';
import ComposeFormContainer from 'themes/glitch/features/compose/containers/compose_form_container';
import NotificationsContainer from 'themes/glitch/features/ui/containers/notifications_container';
import LoadingBarContainer from 'themes/glitch/features/ui/containers/loading_bar_container';
import ModalContainer from 'themes/glitch/features/ui/containers/modal_container';

export default class Compose extends React.PureComponent {

  render () {
    return (
      <div>
        <ComposeFormContainer />
        <NotificationsContainer />
        <ModalContainer />
        <LoadingBarContainer className='loading-bar' />
      </div>
    );
  }

}
