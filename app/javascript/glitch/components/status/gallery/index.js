//  Package imports  //
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

//  Mastodon imports  //
import IconButton from '../../../../mastodon/components/icon_button';

//  Our imports  //
import StatusGalleryItem from './item';

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

@injectIntl
export default class StatusGallery extends React.PureComponent {

  static propTypes = {
    sensitive: PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    letterbox: PropTypes.bool,
    fullwidth: PropTypes.bool,
    height: PropTypes.number.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    autoPlayGif: PropTypes.bool.isRequired,
  };

  state = {
    visible: !this.props.sensitive,
  };

  handleOpen = () => {
    this.setState({ visible: !this.state.visible });
  }

  handleClick = (index) => {
    this.props.onOpenMedia(this.props.media, index);
  }

  render () {
    const { media, intl, sensitive, letterbox, fullwidth } = this.props;

    let children;

    if (!this.state.visible) {
      let warning;

      if (sensitive) {
        warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
      } else {
        warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
      }

      children = (
        <div role='button' tabIndex='0' className='media-spoiler' onClick={this.handleOpen}>
          <span className='media-spoiler__warning'>{warning}</span>
          <span className='media-spoiler__trigger'><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </div>
      );
    } else {
      const size = media.take(4).size;
      children = media.take(4).map((attachment, i) => <StatusGalleryItem key={attachment.get('id')} onClick={this.handleClick} attachment={attachment} autoPlayGif={this.props.autoPlayGif} index={i} size={size} letterbox={letterbox} />);
    }

    return (
      <div className={`media-gallery ${fullwidth ? 'full-width' : ''}`} style={{ height: `${this.props.height}px` }}>
        <div className={`spoiler-button ${this.state.visible ? 'spoiler-button--visible' : ''}`}>
          <IconButton title={intl.formatMessage(messages.toggle_visible)} icon={this.state.visible ? 'eye' : 'eye-slash'} overlay onClick={this.handleOpen} />
        </div>

        {children}
      </div>
    );
  }

}
