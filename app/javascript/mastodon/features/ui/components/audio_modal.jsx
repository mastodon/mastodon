import PropTypes from 'prop-types';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import Audio from 'mastodon/features/audio';
import Footer from 'mastodon/features/picture_in_picture/components/footer';

const mapStateToProps = (state, { statusId }) => ({
  status: state.getIn(['statuses', statusId]),
  accountStaticAvatar: state.getIn(['accounts', state.getIn(['statuses', statusId, 'account']), 'avatar_static']),
});

class AudioModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    statusId: PropTypes.string.isRequired,
    status: ImmutablePropTypes.map.isRequired,
    accountStaticAvatar: PropTypes.string.isRequired,
    options: PropTypes.shape({
      autoPlay: PropTypes.bool,
    }),
    onClose: PropTypes.func.isRequired,
    onChangeBackgroundColor: PropTypes.func.isRequired,
  };

  render () {
    const { media, status, accountStaticAvatar, onClose } = this.props;
    const options = this.props.options || {};
    const language = status.getIn(['translation', 'language']) || status.get('language');
    const description = media.getIn(['translation', 'description']) || media.get('description');

    return (
      <div className='modal-root__modal audio-modal'>
        <div className='audio-modal__container'>
          <Audio
            src={media.get('url')}
            alt={description}
            lang={language}
            duration={media.getIn(['meta', 'original', 'duration'], 0)}
            height={150}
            poster={media.get('preview_url') || accountStaticAvatar}
            backgroundColor={media.getIn(['meta', 'colors', 'background'])}
            foregroundColor={media.getIn(['meta', 'colors', 'foreground'])}
            accentColor={media.getIn(['meta', 'colors', 'accent'])}
            autoPlay={options.autoPlay}
          />
        </div>

        <div className='media-modal__overlay'>
          {status && <Footer statusId={status.get('id')} withOpenButton onClose={onClose} />}
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, null, null, { forwardRef: true })(AudioModal);
