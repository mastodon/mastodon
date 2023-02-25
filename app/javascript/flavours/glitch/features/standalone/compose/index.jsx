import React from 'react';
import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import NotificationsContainer from 'flavours/glitch/features/ui/containers/notifications_container';
import LoadingBarContainer from 'flavours/glitch/features/ui/containers/loading_bar_container';
import ModalContainer from 'flavours/glitch/features/ui/containers/modal_container';

export default class Compose extends React.PureComponent {

  render () {
    return (
      <div>
        <ComposeFormContainer autoFocus />
        <NotificationsContainer />
        <ModalContainer />
        <LoadingBarContainer className='loading-bar' />
      </div>
    );
  }

}
