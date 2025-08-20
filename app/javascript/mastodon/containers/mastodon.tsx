import { PureComponent } from 'react';

import { Helmet } from 'react-helmet';
// import { Route } from 'react-router-dom';

import { Provider as ReduxProvider } from 'react-redux';

import { RouterProvider, createRouter } from '@tanstack/react-router';
// import { ScrollContext } from 'react-router-scroll-4';

import { routeTree } from '@/mastodon/routeTree.gen';
import { fetchCustomEmojis } from 'mastodon/actions/custom_emojis';
import { hydrateStore } from 'mastodon/actions/store';
import { connectUserStream } from 'mastodon/actions/streaming';
import ErrorBoundary from 'mastodon/components/error_boundary';
// import { Router } from 'mastodon/components/router';
// import UI from 'mastodon/features/ui';
import { BodyScrollLock } from 'mastodon/features/ui/components/body_scroll_lock';
import {
  IdentityContext,
  createIdentityContext,
} from 'mastodon/identity_context';
import initialState, { title as siteTitle } from 'mastodon/initial_state';
import { IntlProvider } from 'mastodon/locales';
import { store } from 'mastodon/store';
import { isProduction } from 'mastodon/utils/environment';

const title = isProduction() ? siteTitle : `${siteTitle} (Dev)`;

const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);
if (initialState?.meta.me) {
  store.dispatch(fetchCustomEmojis());
}

// Create a new router instance
const router = createRouter({
  routeTree,
  context: { store },
});

// Register the router instance for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

// eslint-disable-next-line import/no-default-export
export default class Mastodon extends PureComponent {
  identity = createIdentityContext(initialState);

  componentDidMount() {
    if (this.identity.signedIn) {
      this.disconnect = store.dispatch(connectUserStream());
    }
  }

  componentWillUnmount() {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  shouldUpdateScroll(prevRouterProps, { location }) {
    return !(
      location.state?.mastodonModalKey &&
      location.state?.mastodonModalKey !==
        prevRouterProps?.location?.state?.mastodonModalKey
    );
  }

  render() {
    return (
      <IdentityContext.Provider value={this.identity}>
        <IntlProvider>
          <ReduxProvider store={store}>
            <ErrorBoundary>
              {/* <Router>
                <ScrollContext shouldUpdateScroll={this.shouldUpdateScroll}>
                  <Route path='/' component={UI} />
                </ScrollContext>

              </Router> */}
              <RouterProvider
                router={router}
                context={{ identity: this.identity }}
              />
              <BodyScrollLock />
              <Helmet defaultTitle={title} titleTemplate={`%s - ${title}`} />
            </ErrorBoundary>
          </ReduxProvider>
        </IntlProvider>
      </IdentityContext.Provider>
    );
  }
}
