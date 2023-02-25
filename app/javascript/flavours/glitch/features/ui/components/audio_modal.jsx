import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Audio from 'flavours/glitch/features/audio';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Footer from 'flavours/glitch/features/picture_in_picture/components/footer';

const mapStateToProps = (state, { statusId }) => ({
  accountStaticAvatar: state.getIn(['accounts', state.getIn(['statuses', statusId, 'account']), 'avatar_static']),
});

export default @connect(mapStateToProps)
class AudioModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    statusId: PropTypes.string.isRequired,
    accountStaticAvatar: PropTypes.string.isRequired,
    options: PropTypes.shape({
      autoPlay: PropTypes.bool,
    }),
    onClose: PropTypes.func.isRequired,
    onChangeBackgroundColor: PropTypes.func.isRequired,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  render () {
    const { media, accountStaticAvatar, statusId, onClose } = this.props;
    const options = this.props.options || {};

    return (
      <div className='modal-root__modal audio-modal'>
        <div className='audio-modal__container'>
          <Audio
            src={media.get('url')}
            alt={media.get('description')}
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
          {statusId && <Footer statusId={statusId} withOpenButton onClose={onClose} />}
        </div>
      </div>
    );
  }

}
