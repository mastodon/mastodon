import LoadingIndicator from '../../../components/loading_indicator';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ExtendedVideoPlayer from '../../../components/extended_video_player';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' }
});

const closeStyle = {
  position: 'absolute',
  zIndex: '100',
  top: '4px',
  right: '4px'
};

const VideoModal = React.createClass({

  propTypes: {
    media: ImmutablePropTypes.map.isRequired,
    time: React.PropTypes.number,
    onClose: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { media, intl, time, onClose } = this.props;

    const url = media.get('url');

    return (
      <div className='modal-root__modal media-modal'>
        <div>
          <div style={closeStyle}><IconButton title={intl.formatMessage(messages.close)} icon='times' overlay onClick={onClose} /></div>
          <ExtendedVideoPlayer src={url} muted={false} controls={true} time={time} />
        </div>
      </div>
    );
  }

});

export default injectIntl(VideoModal);
