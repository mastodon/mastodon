import { AlertsController } from '@/mastodon/components/alerts_controller';
import { ComposeForm } from '@/mastodon/features/compose/form';
import LoadingBarContainer from '@/mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from '@/mastodon/features/ui/containers/modal_container';
import { usePreventClosingPage } from '@/mastodon/hooks/usePreventClosingPage';
import { selectComposerIsChanged } from '@/mastodon/reducers/slices/composer';
import { useAppSelector } from '@/mastodon/store';

export const Compose: React.FC = () => {
  const isComposerChanged = useAppSelector(selectComposerIsChanged);

  usePreventClosingPage(isComposerChanged);

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
