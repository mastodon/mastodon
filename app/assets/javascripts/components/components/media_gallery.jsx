import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import { FormattedMessage } from 'react-intl';

const outerStyle = {
  marginTop: '8px',
  overflow: 'hidden',
  width: '100%',
  boxSizing: 'border-box'
};

const spoilerStyle = {
  background: '#000',
  color: '#fff',
  textAlign: 'center',
  height: '100%',
  cursor: 'pointer'
};

const spoilerSpanStyle = {
  display: 'block',
  fontSize: '14px',
  paddingTop: '45%'
};

const spoilerSubSpanStyle = {
  fontSize: '11px',
  fontWeight: '500'
};

const MediaGallery = React.createClass({

  getInitialState () {
    return {
      visible: false
    };
  },

  propTypes: {
    sensitive: React.PropTypes.bool,
    media: ImmutablePropTypes.list.isRequired,
    height: React.PropTypes.number.isRequired,
    onOpenMedia: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick (url, e) {
    if (e.button === 0) {
      e.preventDefault();
      this.props.onOpenMedia(url);
    }

    e.stopPropagation();
  },

  handleOpen () {
    this.setState({ visible: true });
  },

  render () {
    const { media, sensitive } = this.props;

    let children;

    if (sensitive && !this.state.visible) {
      children = (
        <div style={spoilerStyle} onClick={this.handleOpen}>
          <span style={spoilerSpanStyle}><FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' /></span>
          <span style={spoilerSubSpanStyle}><FormattedMessage id='status.sensitive_toggle' defaultMessage='Click to view' /></span>
        </div>
      );
    } else {
      const size = media.take(4).size;

      children = media.take(4).map((attachment, i) => {
        let width  = 50;
        let height = 100;
        let top    = 'auto';
        let left   = 'auto';
        let bottom = 'auto';
        let right  = 'auto';

        if (size === 1) {
          width = 100;
        }

        if (size === 4 || (size === 3 && i > 0)) {
          height = 50;
        }

        if (size === 2) {
          if (i === 0) {
            right = '2px';
          } else {
            left = '2px';
          }
        } else if (size === 3) {
          if (i === 0) {
            right = '2px';
          } else if (i > 0) {
            left = '2px';
          }

          if (i === 1) {
            bottom = '2px';
          } else if (i > 1) {
            top = '2px';
          }
        } else if (size === 4) {
          if (i === 0 || i === 2) {
            right = '2px';
          }

          if (i === 1 || i === 3) {
            left = '2px';
          }

          if (i < 2) {
            bottom = '2px';
          } else {
            top = '2px';
          }
        }

        return (
          <div key={attachment.get('id')} style={{ boxSizing: 'border-box', position: 'relative', left: left, top: top, right: right, bottom: bottom, float: 'left', border: 'none', display: 'block', width: `${width}%`, height: `${height}%` }}>
            <a href={attachment.get('url')} onClick={this.handleClick.bind(this, attachment.get('url'))} target='_blank' style={{ display: 'block', width: '100%', height: '100%', background: `url(${attachment.get('preview_url')}) no-repeat center`, textDecoration: 'none', backgroundSize: 'cover', cursor: 'zoom-in' }} />
          </div>
        );
      });
    }

    return (
      <div style={{ ...outerStyle, height: `${this.props.height}px` }}>
        {children}
      </div>
    );
  }

});

export default MediaGallery;
