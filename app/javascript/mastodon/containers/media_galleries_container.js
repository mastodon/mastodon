import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import MediaGallery from '../components/media_gallery';
import ModalRoot from '../components/modal_root';
import MediaModal from '../features/ui/components/media_modal';
import { fromJS } from 'immutable';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export default class MediaGalleriesContainer extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
    galleries: PropTypes.object.isRequired,
  };

  state = {
    media: null,
    index: null,
  };

  handleOpenMedia = (media, index) => {
    document.body.classList.add('media-gallery-standalone__body');
    this.setState({ media, index });
  }

  handleCloseMedia = () => {
    document.body.classList.remove('media-gallery-standalone__body');
    this.setState({ media: null, index: null });
  }

  render () {
    const { locale, galleries } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <React.Fragment>
          {[].map.call(galleries, gallery => {
            const { media, ...props } = JSON.parse(gallery.getAttribute('data-props'));

            return ReactDOM.createPortal(
              <MediaGallery
                {...props}
                media={fromJS(media)}
                onOpenMedia={this.handleOpenMedia}
              />,
              gallery
            );
          })}
          <ModalRoot onClose={this.handleCloseMedia}>
            {this.state.media === null || this.state.index === null ? null : (
              <MediaModal
                media={this.state.media}
                index={this.state.index}
                onClose={this.handleCloseMedia}
              />
            )}
          </ModalRoot>
        </React.Fragment>
      </IntlProvider>
    );
  }

}
