import { AlertsController } from '@/mastodon/components/alerts_controller';
import { ComposeForm } from '@/mastodon/features/compose/form';
import LoadingBarContainer from '@/mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from '@/mastodon/features/ui/containers/modal_container';

export const Compose: React.FC = () => {
  return (
    <>
      <ComposeForm autoFocus headless redirectOnSuccess />
      <AlertsController />
      <ModalContainer />
      <LoadingBarContainer className='loading-bar' />
    </>
  );
};

// eslint-disable-next-line import/no-default-export
export default Compose;
