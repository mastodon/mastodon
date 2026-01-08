import { AlertsController } from 'mastodon/components/alerts_controller';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import LoadingBarContainer from 'mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from 'mastodon/features/ui/containers/modal_container';

const Compose = () => (
  <>
    <ComposeFormContainer autoFocus withoutNavigation redirectOnSuccess />
    <AlertsController />
    <ModalContainer />
    <LoadingBarContainer className='loading-bar' />
  </>
);

export default Compose;
