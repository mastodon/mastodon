import React from 'react';
import PropTypes from 'prop-types';

export default class ExtendedVideoPlayer extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
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
    const { src, muted, controls, alt } = this.props;

    return (
      <div className='extended-video-player'>
        <video
          ref={this.setRef}
          src={src}
          autoPlay
          role='button'
          tabIndex='0'
          aria-label={alt}
          muted={muted}
          controls={controls}
          loop={!controls}
        />
      </div>
    );
  }

}
