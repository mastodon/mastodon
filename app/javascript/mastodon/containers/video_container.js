import React from 'react';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import Video from '../features/video';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export default class VideoContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  render () {
    const { locale, ...props } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Video {...props} />
      </IntlProvider>
    );
  }

}
