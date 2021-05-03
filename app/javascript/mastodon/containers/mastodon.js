import React from 'react';
import { Provider, connect } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { INTRODUCTION_VERSION } from '../actions/onboarding';
import { BrowserRouter, Route } from 'react-router-dom';
import { ScrollContext } from 'react-router-scroll-4';
import UI from '../features/ui';
import Introduction from '../features/introduction';
import { fetchCustomEmojis } from '../actions/custom_emojis';
import { hydrateStore } from '../actions/store';
import { connectUserStream } from '../actions/streaming';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import { previewState as previewMediaState } from 'mastodon/features/ui/components/media_modal';
import { previewState as previewVideoState } from 'mastodon/features/ui/components/video_modal';
import initialState from '../initial_state';
import ErrorBoundary from '../components/error_boundary';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export const store = configureStore();
const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);
store.dispatch(fetchCustomEmojis());

const mapStateToProps = state => ({
  showIntroduction: state.getIn(['settings', 'introductionVersion'], 0) < INTRODUCTION_VERSION,
});

@connect(mapStateToProps)
class MastodonMount extends React.PureComponent {

  static propTypes = {
    showIntroduction: PropTypes.bool,
  };

  shouldUpdateScroll (_, { location }) {
    return location.state !== previewMediaState && location.state !== previewVideoState;
  }

  render () {
    const { showIntroduction } = this.props;

    if (showIntroduction) {
      return <Introduction />;
    }

    return (
      <BrowserRouter basename='/web'>
        <ScrollContext shouldUpdateScroll={this.shouldUpdateScroll}>
          <Route path='/' component={UI} />
        </ScrollContext>
      </BrowserRouter>
    );
  }

}

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentDidMount() {
    this.disconnect = store.dispatch(connectUserStream());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <ErrorBoundary>
            <MastodonMount />
          </ErrorBoundary>
        </Provider>
      </IntlProvider>
    );
  }

}
