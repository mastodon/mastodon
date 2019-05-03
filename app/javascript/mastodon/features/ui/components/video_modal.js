import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Video from 'mastodon/features/video';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';

export const previewState = 'previewVideoModal';

export default class VideoModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    status: ImmutablePropTypes.map,
    time: PropTypes.number,
    onClose: PropTypes.func.isRequired,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  componentDidMount () {
    if (this.context.router) {
      const history = this.context.router.history;

      history.push(history.location.pathname, previewState);

      this.unlistenHistory = history.listen(() => {
        this.props.onClose();
      });
    }
  }

  componentWillUnmount () {
    if (this.context.router) {
      this.unlistenHistory();

      if (this.context.router.history.location.state === previewState) {
        this.context.router.history.goBack();
      }
    }
  }

  handleStatusClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
    }
  }

  render () {
    const { media, status, time, onClose } = this.props;

    const link = status && <a href={status.get('url')} onClick={this.handleStatusClick}><FormattedMessage id='lightbox.view_context' defaultMessage='View context' /></a>;

    return (
      <div className='modal-root__modal video-modal'>
        <div>
          <Video
            preview={media.get('preview_url')}
            blurhash={media.get('blurhash')}
            src={media.get('url')}
            startTime={time}
            onCloseVideo={onClose}
            link={link}
            detailed
            alt={media.get('description')}
          />
        </div>
      </div>
    );
  }

}
