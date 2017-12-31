import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Motion from '../util/optional_motion';
import spring from 'react-motion/lib/spring';
import getPanoramaData from '../util/get_panorama_data';
import { PanoramaViewer as PanoramaViewerAsync } from '../util/async-components';

let PanoramaViewer; // async

export default class ImageLoader extends React.PureComponent {

  static propTypes = {
    alt: PropTypes.string,
    src: PropTypes.string.isRequired,
    previewSrc: PropTypes.string,
    width: PropTypes.number,
    height: PropTypes.number,
  }

  static defaultProps = {
    alt: '',
    width: null,
    height: null,
  };

  state = {
    loading: true,
    canShowPanorama: false,
    panoramaData: null,
    panorama: false,
    error: false,
  }

  removers = [];

  get canvasContext() {
    if (!this.canvas) {
      return null;
    }
    this._canvasContext = this._canvasContext || this.canvas.getContext('2d');
    return this._canvasContext;
  }

  componentDidMount () {
    this.loadImage(this.props);
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.src !== nextProps.src) {
      this.loadImage(nextProps);
    }
  }

  loadImage (props) {
    this.removeEventListeners();
    this.setState({ loading: true, error: false });
    Promise.all([
      props.previewSrc && this.loadPreviewCanvas(props),
      this.hasSize() && this.loadOriginalImage(props),
    ].filter(Boolean))
      .then(() => {
        this.setState({ loading: false, error: false });
        this.clearPreviewCanvas();
        this.checkForPanorama();
      })
      .catch(() => this.setState({ loading: false, error: true }));
  }

  loadPreviewCanvas = ({ previewSrc, width, height }) => new Promise((resolve, reject) => {
    const image = new Image();
    const removeEventListeners = () => {
      image.removeEventListener('error', handleError);
      image.removeEventListener('load', handleLoad);
    };
    const handleError = () => {
      removeEventListeners();
      reject();
    };
    const handleLoad = () => {
      removeEventListeners();
      this.canvasContext.drawImage(image, 0, 0, width, height);
      resolve();
    };
    image.addEventListener('error', handleError);
    image.addEventListener('load', handleLoad);
    image.src = previewSrc;
    this.removers.push(removeEventListeners);
  })

  clearPreviewCanvas () {
    const { width, height } = this.canvas;
    this.canvasContext.clearRect(0, 0, width, height);
  }

  loadOriginalImage = ({ src }) => new Promise((resolve, reject) => {
    const image = new Image();
    const removeEventListeners = () => {
      image.removeEventListener('error', handleError);
      image.removeEventListener('load', handleLoad);
    };
    const handleError = () => {
      removeEventListeners();
      reject();
    };
    const handleLoad = () => {
      removeEventListeners();
      this.image = image;
      resolve();
    };
    image.addEventListener('error', handleError);
    image.addEventListener('load', handleLoad);
    image.src = src;
    this.removers.push(removeEventListeners);
  });

  removeEventListeners () {
    this.removers.forEach(listeners => listeners());
    this.removers = [];
  }

  hasSize () {
    const { width, height } = this.props;
    return typeof width === 'number' && typeof height === 'number';
  }

  checkForPanorama () {
    getPanoramaData(this.props.src).then(result => {
      if (result) {
        this.setState({
          panoramaData: result,
          panorama: result.enabledInitially,
          canShowPanorama: !!PanoramaViewer,
        });

        if (!PanoramaViewer) {
          PanoramaViewerAsync().then(module => {
            PanoramaViewer = module.default;
            this.setState({ canShowPanorama: true });
          }).catch(() => {});
        }
      }
    }).catch(() => {});
  }

  setCanvasRef = c => {
    this.canvas = c;
  }

  togglePanorama = () => {
    this.setState({ panorama: !this.state.panorama });
  }

  render () {
    const { alt, src, width, height } = this.props;
    const { loading, panorama, panoramaData, canShowPanorama } = this.state;

    const className = classNames('image-loader', {
      'image-loader--loading': loading,
      'image-loader--amorphous': !this.hasSize(),
    });

    return (
      <div className={className}>
        <canvas
          className='image-loader__preview-canvas'
          width={width}
          height={height}
          ref={this.setCanvasRef}
          style={{ opacity: loading ? 1 : 0 }}
        />

        {!loading && panoramaData && canShowPanorama && (
          <button
            onClick={this.togglePanorama}
            aria-label='Toggle Panorama'
            title='Toggle Panorama'
            className='image-loader__panorama-button icon-button'
            tabIndex='0'
          >
            <i className={panorama ? 'fa fa-picture-o' : 'fa fa-globe'} />
          </button>
        )}

        {!loading && (
          <Motion
            defaultStyle={{ sphere: 0 }}
            style={{ sphere: spring(+(panorama && canShowPanorama)) }}
          >
            {({ sphere }) => {
              return sphere ? (
                <PanoramaViewer
                  alt={alt}
                  className='image-loader__panorama'
                  image={this.image}
                  width={width}
                  height={height}
                  panoramaData={panoramaData}
                  sphere={sphere}
                />
              ) : (
                <img
                  alt={alt}
                  className='image-loader__img'
                  src={src}
                  width={width}
                  height={height}
                />
              );
            }}
          </Motion>
        )}
      </div>
    );
  }

}
