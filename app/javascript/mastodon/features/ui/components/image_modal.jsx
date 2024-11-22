import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { IconButton } from 'mastodon/components/icon_button';

import ImageLoader from './image_loader';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

class ImageModal extends PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    navigationHidden: false,
  };

  toggleNavigation = () => {
    this.setState(prevState => ({
      navigationHidden: !prevState.navigationHidden,
    }));
  };

  render () {
    const { intl, src, alt, onClose } = this.props;
    const { navigationHidden } = this.state;

    const navigationClassName = classNames('media-modal__navigation', {
      'media-modal__navigation--hidden': navigationHidden,
    });

    return (
      <div className='modal-root__modal media-modal'>
        <div className='media-modal__closer' role='presentation' onClick={onClose} >
          <ImageLoader
            src={src}
            width={400}
            height={400}
            alt={alt}
            onClick={this.toggleNavigation}
          />
        </div>

        <div className={navigationClassName}>
          <IconButton className='media-modal__close' title={intl.formatMessage(messages.close)} icon='times' iconComponent={CloseIcon} onClick={onClose} size={40} />
        </div>
      </div>
    );
  }

}

export default injectIntl(ImageModal);
