import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { Helmet } from 'react-helmet';
import { Route } from 'react-router-dom';

import { Provider as ReduxProvider } from 'react-redux';

import { ScrollContext } from 'react-router-scroll-4';

import { fetchCustomEmojis } from 'mastodon/actions/custom_emojis';
import { hydrateStore } from 'mastodon/actions/store';
import { connectUserStream } from 'mastodon/actions/streaming';
import ErrorBoundary from 'mastodon/components/error_boundary';
import { Router } from 'mastodon/components/router';
import UI from 'mastodon/features/ui';
import initialState, { title as siteTitle } from 'mastodon/initial_state';
import { IntlProvider } from 'mastodon/locales';
import { store } from 'mastodon/store';

import { Context as IdentityContext, createLegacyIdentityContext } from './identity_context';

const title = process.env.NODE_ENV === 'production' ? siteTitle : `${siteTitle} (Dev)`;

const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);
if (initialState.meta.me) {
  store.dispatch(fetchCustomEmojis());
}

export default class Mastodon extends PureComponent {
  static childContextTypes = {
    identity: PropTypes.shape({
      signedIn: PropTypes.bool.isRequired,
      accountId: PropTypes.string,
      disabledAccountId: PropTypes.string,
      accessToken: PropTypes.string,
    }).isRequired,
  };

  identity = createLegacyIdentityContext(initialState);

  getChildContext() {
    return {
      identity: this.identity,
    };
  }

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
    return !(location.state?.mastodonModalKey && location.state?.mastodonModalKey !== prevRouterProps?.location?.state?.mastodonModalKey);
  }

  render() {
    return (
      <IntlProvider>
        <ReduxProvider store={store}>
          <ErrorBoundary>
            <Router>
              <ScrollContext shouldUpdateScroll={this.shouldUpdateScroll}>
                <IdentityContext.Provider value={this.identity}>
                  <Route path='/' component={UI} />
                </IdentityContext.Provider>
              </ScrollContext>
            </Router>

            <Helmet defaultTitle={title} titleTemplate={`%s - ${title}`} />
          </ErrorBoundary>
        </ReduxProvider>
      </IntlProvider>
    );
  }

}
