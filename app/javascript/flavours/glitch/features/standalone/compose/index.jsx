import ComposeFormContainer from 'flavours/glitch/features/compose/containers/compose_form_container';
import LoadingBarContainer from 'flavours/glitch/features/ui/containers/loading_bar_container';
import ModalContainer from 'flavours/glitch/features/ui/containers/modal_container';
import NotificationsContainer from 'flavours/glitch/features/ui/containers/notifications_container';

const Compose = () => (
  <>
    <ComposeFormContainer autoFocus withoutNavigation />
    <NotificationsContainer />
    <ModalContainer />
    <LoadingBarContainer className='loading-bar' />
  </>
);

export default Compose;
