import { PureComponent } from 'react';

import { Helmet } from 'react-helmet';
import { Route } from 'react-router-dom';

import { Provider as ReduxProvider } from 'react-redux';

import { ScrollContext } from 'react-router-scroll-4';

import { fetchCustomEmojis } from 'flavours/glitch/actions/custom_emojis';
import { checkDeprecatedLocalSettings } from 'flavours/glitch/actions/local_settings';
import { hydrateStore } from 'flavours/glitch/actions/store';
import { connectUserStream } from 'flavours/glitch/actions/streaming';
import ErrorBoundary from 'flavours/glitch/components/error_boundary';
import { Router } from 'flavours/glitch/components/router';
import UI from 'flavours/glitch/features/ui';
import { IdentityContext, createIdentityContext } from 'flavours/glitch/identity_context';
import initialState, { title as siteTitle } from 'flavours/glitch/initial_state';
import { IntlProvider } from 'flavours/glitch/locales';
import { store } from 'flavours/glitch/store';
import { isProduction } from 'flavours/glitch/utils/environment';

const title = isProduction() ? siteTitle : `${siteTitle} (Dev)`;

const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);

// check for deprecated local settings
store.dispatch(checkDeprecatedLocalSettings());

if (initialState.meta.me) {
  store.dispatch(fetchCustomEmojis());
}

export default class Mastodon extends PureComponent {
  identity = createIdentityContext(initialState);

  componentDidMount() {
    if (this.identity.signedIn) {
      this.disconnect = store.dispatch(connectUserStream());
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  shouldUpdateScroll (prevRouterProps, { location }) {
    return !(location.state?.mastodonModalKey && location.state?.mastodonModalKey !== prevRouterProps?.location?.state?.mastodonModalKey);
  }

  render () {
    return (
      <IdentityContext.Provider value={this.identity}>
        <IntlProvider>
          <ReduxProvider store={store}>
            <ErrorBoundary>
              <Router>
                <ScrollContext shouldUpdateScroll={this.shouldUpdateScroll}>
                  <Route path='/' component={UI} />
                </ScrollContext>
              </Router>

              <Helmet defaultTitle={title} titleTemplate={`%s - ${title}`} />
            </ErrorBoundary>
          </ReduxProvider>
        </IntlProvider>
      </IdentityContext.Provider>
    );
  }

}
