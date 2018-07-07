import React from 'react';
import PropTypes from 'prop-types';
import ReactAudioPlayer from 'react-audio-player';
import { connect } from 'react-redux';
import { playerUrl } from '../../../initial_state';
import * as playerActions from '../../../actions/audio_player';

@connect(state => ({ ...state.get('audioPlayer') }), (dispatch) => ({
  setError: (error) => dispatch(playerActions.setError(error)),
  setPaused: () => dispatch(playerActions.setPaused()),
  setLoading: () => dispatch(playerActions.setLoading()),
  finishedLoading: () => dispatch(playerActions.finishedLoading()),
}))
export class AudioPlayer extends React.Component {

  static propTypes = {
    isPlaying: PropTypes.bool,
    volume: PropTypes.number,
    setError: PropTypes.func,
    setPaused: PropTypes.func,
    setLoading: PropTypes.func,
    finishedLoading: PropTypes.func,
    error: PropTypes.any,
  };

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    this.audioPlayer.audioEl.load();
  }

  componentDidUpdate(prevProps) {
    if (!prevProps) return;
    if (prevProps.isPlaying === false && this.props.isPlaying === true) {
      this.audioPlayer.audioEl.play();
    } else if (prevProps.isPlaying === true && this.props.isPlaying === false) {
      this.audioPlayer.audioEl.pause();
    }
  }

  setPlayerRef = (element) => {
    this.audioPlayer = element;
  };

  onPlaybackError = () => {
    const audioEl = this.audioPlayer.audioEl;
    this.props.setError(audioEl.error);
    if (audioEl.error.code !== 4) {
      this.props.setLoading();
      audioEl.load();
    }
  };

  onMetaLoaded = () => {
    this.props.finishedLoading()
  };

  onPlaybackPossible = () => {
    if (this.props.isPlaying && this.props.error && this.props.error !== -1 && this.props.error.code !== 4) {
      this.audioPlayer.audioEl.play();
      this.props.setError({ code: -1 });
    }
  };

  setPaused = () => {
    this.props.setPaused();
  };

  render() {
    return (<ReactAudioPlayer
      className={'column-player'}
      src={playerUrl}
      ref={this.setPlayerRef}
      volume={this.props.volume  || 0.6}
      onLoadedMetadata={this.onMetaLoaded}
      onError={this.onPlaybackError}
      onCanPlay={this.onPlaybackPossible}
      onEnded={this.setPaused}
    />);
  }

}

export default AudioPlayer;
