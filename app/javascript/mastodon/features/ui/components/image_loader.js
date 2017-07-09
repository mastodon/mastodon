import React from 'react';
import PropTypes from 'prop-types';

class ImageLoader extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
    previewSrc: PropTypes.string.isRequired,
    width: PropTypes.number.isRequired,
    height: PropTypes.number.isRequired,
  }

  state = {
    loading: true,
    error: false,
  }

  componentWillMount() {
    this._loadImage(this.props.src);
  }

  componentWillReceiveProps(props) {
    this._loadImage(props.src);
  }

  _loadImage(src) {
    const image = new Image();

    image.onerror = () => this.setState({ loading: false, error: true });
    image.onload  = () => this.setState({ loading: false, error: false });

    image.src = src;

    this.setState({ loading: true });
  }

  render() {
    const { src, previewSrc, width, height } = this.props;
    const { loading, error } = this.state;

    return (
      <div className='image-loader'>
        <img // eslint-disable-line jsx-a11y/img-has-alt
          className='image-loader__img'
          src={src}
          width={width}
          height={height}
        />

        {loading &&
          <img // eslint-disable-line jsx-a11y/img-has-alt
            src={previewSrc}
            className='image-loader__preview-img'
          />
        }
      </div>
    );
  }

}

export default ImageLoader;
