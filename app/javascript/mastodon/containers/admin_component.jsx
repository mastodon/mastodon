import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { IntlProvider } from 'react-intl';

import { getLocale } from '../locales';

const { messages } = getLocale();

export default class AdminComponent extends PureComponent {

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
