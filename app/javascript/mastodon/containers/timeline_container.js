import React from 'react';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { hydrateStore } from '../actions/store';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import PublicTimeline from '../features/standalone/public_timeline';
import HashtagTimeline from '../features/standalone/hashtag_timeline';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();
const initialStateContainer = document.getElementById('initial-state');

if (initialStateContainer !== null) {
  const initialState = JSON.parse(initialStateContainer.textContent);
  store.dispatch(hydrateStore(initialState));
}

export default class TimelineContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    hashtag: PropTypes.string,
  };

  render () {
    const { locale, hashtag } = this.props;

    let timeline;

    if (hashtag) {
      timeline = <HashtagTimeline hashtag={hashtag} />;
    } else {
      timeline = <PublicTimeline />;
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
