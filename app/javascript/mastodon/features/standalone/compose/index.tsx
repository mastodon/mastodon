import { lazy, Suspense, useEffect } from 'react';

import { AlertsController } from '@/mastodon/components/alerts_controller';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import ComposeFormContainer from '@/mastodon/features/compose/containers/compose_form_container';
import LoadingBarContainer from '@/mastodon/features/ui/containers/loading_bar_container';
import ModalContainer from '@/mastodon/features/ui/containers/modal_container';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

const ComposeLazyForm = lazy(() =>
  import('@/mastodon/features/compose/redesign/index').then(
    ({ RedesignComposeForm }) => ({
      default: RedesignComposeForm,
    }),
  ),
);

export const Compose: React.FC = () => {
  return (
    <>
      {isRedesignEnabled() ? (
        <RedesignCompose />
      ) : (
        <ComposeFormContainer autoFocus withoutNavigation redirectOnSuccess />
      )}
      <AlertsController />
      <ModalContainer />
      <LoadingBarContainer className='loading-bar' />
    </>
  );
};

const RedesignCompose: React.FC = () => {
  useEffect(() => {
    document.documentElement.dataset.redesign = 'true';
    return () => {
      document.documentElement.dataset.redesign = 'false';
    };
  }, []);

  return (
    <Suspense fallback={<LoadingIndicator />}>
      <ComposeLazyForm autoFocus headless redirectOnSuccess />
    </Suspense>
  );
};

// eslint-disable-next-line import/no-default-export
export default Compose;
