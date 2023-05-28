import PropTypes from 'prop-types';
import { Component } from 'react';

import classNames from 'classnames';

import { connect } from 'react-redux';

import { removePictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import Audio from 'flavours/glitch/features/audio';
import Video from 'flavours/glitch/features/video';

import Footer from './components/footer';
import Header from './components/header';

const mapStateToProps = state => ({
  ...state.get('picture_in_picture'),
  left: state.getIn(['local_settings', 'media', 'pop_in_position']) === 'left',
});

class PictureInPicture extends Component {

  static propTypes = {
    statusId: PropTypes.string,
    accountId: PropTypes.string,
    type: PropTypes.string,
    src: PropTypes.string,
    muted: PropTypes.bool,
    volume: PropTypes.number,
    currentTime: PropTypes.number,
    poster: PropTypes.string,
    backgroundColor: PropTypes.string,
    foregroundColor: PropTypes.string,
    accentColor: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    left: PropTypes.bool,
  };

  handleClose = () => {
    const { dispatch } = this.props;
    dispatch(removePictureInPicture());
  };

  render () {
    const { type, src, currentTime, accountId, statusId, left } = this.props;

    if (!currentTime) {
      return null;
    }

    let player;

    if (type === 'video') {
      player = (
        <Video
          src={src}
          currentTime={this.props.currentTime}
          volume={this.props.volume}
          muted={this.props.muted}
          autoPlay
          inline
          alwaysVisible
        />
      );
    } else if (type === 'audio') {
      player = (
        <Audio
          src={src}
          currentTime={this.props.currentTime}
          volume={this.props.volume}
          muted={this.props.muted}
          poster={this.props.poster}
          backgroundColor={this.props.backgroundColor}
          foregroundColor={this.props.foregroundColor}
          accentColor={this.props.accentColor}
          autoPlay
        />
      );
    }

    return (
      <div className={classNames('picture-in-picture', { left })}>
        <Header accountId={accountId} statusId={statusId} onClose={this.handleClose} />

        {player}

        <Footer statusId={statusId} />
      </div>
    );
  }

}

export default connect(mapStateToProps)(PictureInPicture);
