import React from 'react';
import PropTypes from 'prop-types';

export default class GIFV extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    alt: PropTypes.string,
    width: PropTypes.number,
    height: PropTypes.number,
    onClick: PropTypes.func,
  };

  state = {
    loading: true,
  };

  handleLoadedData = () => {
    this.setState({ loading: false });
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.src !== this.props.src) {
      this.setState({ loading: true });
    }
  }

  handleClick = e => {
    const { onClick } = this.props;

    if (onClick) {
      e.stopPropagation();
      onClick();
    }
  }

  render () {
    const { src, width, height, alt } = this.props;
    const { loading } = this.state;

    return (
      <div className='gifv' style={{ position: 'relative' }}>
        {loading && (
          <canvas
            width={width}
            height={height}
            role='button'
            tabIndex='0'
            aria-label={alt}
            title={alt}
            onClick={this.handleClick}
          />
        )}

        <video
          src={src}
          width={width}
          height={height}
          role='button'
          tabIndex='0'
          aria-label={alt}
          title={alt}
          muted
          loop
          autoPlay
          playsInline
          onClick={this.handleClick}
          onLoadedData={this.handleLoadedData}
          style={{ position: loading ? 'absolute' : 'static', top: 0, left: 0 }}
        />
      </div>
    );
  }

}
