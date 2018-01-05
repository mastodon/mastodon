import React from 'react';
import Composer from 'flavours/glitch/features/composer';
import NotificationsContainer from 'flavours/glitch/features/ui/containers/notifications_container';
import LoadingBarContainer from 'flavours/glitch/features/ui/containers/loading_bar_container';
import ModalContainer from 'flavours/glitch/features/ui/containers/modal_container';

export default class Compose extends React.PureComponent {

  render () {
    return (
      <div>
        <Composer />
        <NotificationsContainer />
        <ModalContainer />
        <LoadingBarContainer className='loading-bar' />
      </div>
    );
  }

}
