import React from 'react';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import MediaGallery from '../components/media_gallery';
import { fromJS } from 'immutable';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export default class MediaGalleryContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    media: PropTypes.array.isRequired,
  };

  handleOpenMedia = () => {}

  render () {
    const { locale, media, ...props } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <MediaGallery
          {...props}
          media={fromJS(media)}
          onOpenMedia={this.handleOpenMedia}
        />
      </IntlProvider>
    );
  }

}
