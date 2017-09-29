import React from 'react';
import PropTypes from 'prop-types';

export default class ExtendedVideoPlayer extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    width: PropTypes.number,
    height: PropTypes.number,
    time: PropTypes.number,
    controls: PropTypes.bool.isRequired,
    muted: PropTypes.bool.isRequired,
  };

  handleLoadedData = () => {
    if (this.props.time) {
      this.video.currentTime = this.props.time;
    }
  }

  componentDidMount () {
    this.video.addEventListener('loadeddata', this.handleLoadedData);
  }

  componentWillUnmount () {
    this.video.removeEventListener('loadeddata', this.handleLoadedData);
  }

  setRef = (c) => {
    this.video = c;
  }

  render () {
    return (
      <div className='extended-video-player'>
        <video
          ref={this.setRef}
          src={this.props.src}
          autoPlay
          muted={this.props.muted}
          controls={this.props.controls}
          loop={!this.props.controls}
        />
      </div>
    );
  }

}
