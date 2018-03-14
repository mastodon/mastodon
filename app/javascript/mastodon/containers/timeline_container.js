import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { hydrateStore } from '../actions/store';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import PublicTimeline from '../features/standalone/public_timeline';
import CommunityTimeline from '../features/standalone/community_timeline';
import HashtagTimeline from '../features/standalone/hashtag_timeline';
import initialState from '../initial_state';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

export default class TimelineContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    hashtag: PropTypes.string,
    showPublicTimeline: PropTypes.bool.isRequired,
  };

  static defaultProps = {
    showPublicTimeline: initialState.settings.known_fediverse,
  };

  render () {
    const { locale, hashtag, showPublicTimeline } = this.props;

    let timeline;

    if (hashtag) {
      timeline = <HashtagTimeline hashtag={hashtag} />;
    } else if (showPublicTimeline) {
      timeline = <PublicTimeline />;
    } else {
      timeline = <CommunityTimeline />;
    }

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          {timeline}
        </Provider>
      </IntlProvider>
    );
  }

}
