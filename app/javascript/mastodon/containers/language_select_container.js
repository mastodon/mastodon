import LanguageSelect from '../components/language_select';
import React, { Fragment } from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import PropTypes from 'prop-types';

import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';

import configureStore from '../store/configureStore';
import { hydrateStore } from '../actions/store';
import initialState from '../initial_state';
import { ImmutablePureComponent } from 'react-immutable-pure-component';

import ModalContainer from '../features/ui/containers/modal_container';
import { openModal } from '../actions/modal';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

const store = configureStore();

if (initialState) {
  store.dispatch(hydrateStore(initialState));
}

export default class LanguageSelectContainer extends ImmutablePureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    supportedLocales: PropTypes.arrayOf(PropTypes.object).isRequired,
  };

  onLocaleChange = () => {
    const { locale, supportedLocales } = this.props;

    store.dispatch(openModal('LANGUAGE_SELECT', {
      locale, supportedLocales,
      onLocaleChange: code => {
        document.cookie = `lang=${code}; expires=0; path=/`;
        document.location.reload();
      },
    }));
  }

  render () {
    const { locale, supportedLocales } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <Fragment>
            <LanguageSelect locale={locale} supportedLocales={supportedLocales} onLocaleChange={this.onLocaleChange} />
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
