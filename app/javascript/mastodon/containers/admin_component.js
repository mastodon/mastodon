import React from 'react';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export default class AdminComponent extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    children: PropTypes.node.isRequired,
  };

  render () {
    const { locale, children } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        {children}
      </IntlProvider>
    );
  }

}
