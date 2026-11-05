import { useEffect } from 'react';

import { Provider } from 'react-redux';

import { hydrateStore } from '@/mastodon/actions/store';
import { FocusTargetProvider } from '@/mastodon/components/navigation_focus_target';
import { Router } from '@/mastodon/components/router';
import { Status } from '@/mastodon/components/status';
import { useRenderSignal } from '@/mastodon/hooks/useRenderSignal';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { initialState } from '@/mastodon/initial_state';
import { IntlProvider } from '@/mastodon/locales';
import { store } from '@/mastodon/store';

const Embed: React.FC<{ id: string }> = ({ id }) => {
  const status = useExpandedStatus(id, true);
  const dispatchRenderSignal = useRenderSignal();

  // This allows us to calculate the correct page height for embeds
  if (status) {
    dispatchRenderSignal();
  }

  return (
    <div className='embed'>
      <Status id={status?.id} />

      {status?.url && (
        <a
          className='embed__overlay'
          href={status.url}
          target='_blank'
          rel='noopener'
          aria-label=''
        />
      )}
    </div>
  );
};

export const EmbedRoot: React.FC<{ id: string }> = ({ id }) => {
  useEffect(() => {
    if (initialState) {
      store.dispatch(hydrateStore(initialState));
    }
  }, []);

  return (
    <IntlProvider>
      <Provider store={store}>
        <Router>
          <FocusTargetProvider>
            <Embed id={id} />
          </FocusTargetProvider>
        </Router>
      </Provider>
    </IntlProvider>
  );
};
