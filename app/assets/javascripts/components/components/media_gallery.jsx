import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import IconButton from './icon_button';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { isIOS } from '../is_mobile';

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' }
});

const outerStyle = {
  marginTop: '8px',
  overflow: 'hidden',
  width: '100%',
  boxSizing: 'border-box',
  position: 'relative'
};

const spoilerStyle = {
  textAlign: 'center',
  height: '100%',
  cursor: 'pointer',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  flexDirection: 'column'
};

const spoilerSpanStyle = {
  display: 'block',
  fontSize: '14px',
};

const spoilerSubSpanStyle = {
  display: 'block',
  fontSize: '11px',
  fontWeight: '500'
};

const spoilerButtonStyle = {
  position: 'absolute',
  top: '4px',
  left: '4px',
  zIndex: '100'
};

const itemStyle = {
  boxSizing: 'border-box',
  position: 'relative',
  float: 'left',
  border: 'none',
  display: 'block'
};

const thumbStyle = {
  display: 'block',
  width: '100%',
  height: '100%',
  textDecoration: 'none',
  backgroundSize: 'cover',
  cursor: 'zoom-in'
};

const gifvThumbStyle = {
  position: 'relative',
  zIndex: '1',
  width: '100%',
  height: '100%',
  objectFit: 'cover',
  top: '50%',
  transform: 'translateY(-50%)',
  cursor: 'zoom-in'
};

const Item = React.createClass({

  propTypes: {
    attachment: ImmutablePropTypes.map.isRequired,
    index: React.PropTypes.number.isRequired,
    size: React.PropTypes.number.isRequired,
    onClick: React.PropTypes.func.isRequired,
    autoPlayGif: React.PropTypes.bool.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick (e) {
    const { index, onClick } = this.props;

    if (e.button === 0) {
      e.preventDefault();
      onClick(index);
    }

    e.stopPropagation();
  },

  render () {
    const { attachment, index, size } = this.props;

    let width  = 50;
    let height = 100;
    let top    = 'auto';
    let left   = 'auto';
    let bottom = 'auto';
    let right  = 'auto';

    if (size === 1) {
      width = 100;
    }

    if (size === 4 || (size === 3 && index > 0)) {
      height = 50;
    }

    if (size === 2) {
      if (index === 0) {
        right = '2px';
      } else {
        left = '2px';
      }
    } else if (size === 3) {
      if (index === 0) {
        right = '2px';
      } else if (index > 0) {
        left = '2px';
      }

      if (index === 1) {
        bottom = '2px';
      } else if (index > 1) {
        top = '2px';
      }
    } else if (size === 4) {
      if (index === 0 || index === 2) {
        right = '2px';
      }

      if (index === 1 || index === 3) {
        left = '2px';
      }

      if (index < 2) {
        bottom = '2px';
      } else {
        top = '2px';
      }
    }

    let thumbnail = '';

    if (attachment.get('type') === 'image') {
      thumbnail = (
        <a
          href={attachment.get('remote_url') ? attachment.get('remote_url') : attachment.get('url')}
          onClick={this.handleClick}
          target='_blank'
          style={{ background: `url(${attachment.get('preview_url')}) no-repeat center`, ...thumbStyle }}
        />
      );
    } else if (attachment.get('type') === 'gifv') {
      const autoPlay = !isIOS() && this.props.autoPlayGif;

      thumbnail = (
        <div style={{ position: 'relative', width: '100%', height: '100%', overflow: 'hidden' }} className={`media-gallery__gifv ${autoPlay ? 'autoplay' : ''}`}>
          <video
            src={attachment.get('url')}
            onClick={this.handleClick}
            autoPlay={autoPlay}
            loop={true}
            muted={true}
            style={gifvThumbStyle}
          />

          <span className='media-gallery__gifv__label'>GIF</span>
        </div>
      );
    }

    return (
      <div key={attachment.get('id')} style={{ ...itemStyle, left: left, top: top, right: right, bottom: bottom, width: `${width}%`, height: `${height}%` }}>
        {thumbnail}
      </div>
    );
  }

});

const MediaGallery = React.createClass({

  getInitialState () {
    return {
      visible: !this.props.sensitive
    };
  },

  propTypes: {
    sensitive: React.PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    height: React.PropTypes.number.isRequired,
    onOpenMedia: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    autoPlayGif: React.PropTypes.bool.isRequired
  },

  mixins: [PureRenderMixin],

  handleOpen (e) {
    this.setState({ visible: !this.state.visible });
  },

  handleClick (index) {
    this.props.onOpenMedia(this.props.media, index);
  },

  render () {
    const { media, intl, sensitive } = this.props;

    let children;

    if (!this.state.visible) {
      let warning;

      if (sensitive) {
        warning = <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />;
      } else {
        warning = <FormattedMessage id='status.media_hidden' defaultMessage='Media hidden' />;
      }

      children = (
        <div role='button' tabIndex='0' style={spoilerStyle} className='media-spoiler' onClick={this.handleOpen}>
          <span style={spoilerSpanStyle}>{warning}</span>
          <span style={spoilerSubSpanStyle}><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </div>
      );
    } else {
      const size = media.take(4).size;
      children = media.take(4).map((attachment, i) => <Item key={attachment.get('id')} onClick={this.handleClick} attachment={attachment} autoPlayGif={this.props.autoPlayGif} index={i} size={size} />);
    }

    return (
      <div style={{ ...outerStyle, height: `${this.props.height}px` }}>
        <div style={{ ...spoilerButtonStyle, display: !this.state.visible ? 'none' : 'block' }}>
          <IconButton title={intl.formatMessage(messages.toggle_visible)} icon={this.state.visible ? 'eye' : 'eye-slash'} overlay onClick={this.handleOpen} />
        </div>

        {children}
      </div>
    );
  }

});

export default injectIntl(MediaGallery);
