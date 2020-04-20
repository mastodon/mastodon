import React, { Fragment } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from 'flavours/glitch/store/configureStore';
import { hydrateStore } from 'flavours/glitch/actions/store';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from 'mastodon/locales';
import PublicTimeline from 'flavours/glitch/features/standalone/public_timeline';
import HashtagTimeline from 'flavours/glitch/features/standalone/hashtag_timeline';
import ModalContainer from 'flavours/glitch/features/ui/containers/modal_container';
import initialState from 'flavours/glitch/util/initial_state';

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
    local: PropTypes.bool,
  };

  static defaultProps = {
    local: !initialState.settings.known_fediverse,
  };

  render () {
    const { locale, hashtag, local } = this.props;

    let timeline;

    if (hashtag) {
      timeline = <HashtagTimeline hashtag={hashtag} local={local} />;
    } else {
      timeline = <PublicTimeline local={local} />;
    }

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <Fragment>
            {timeline}

            {ReactDOM.createPortal(
              <ModalContainer />,
              document.getElementById('modal-container'),
            )}
          </Fragment>
        </Provider>
      </IntlProvider>
    );
  }

}
