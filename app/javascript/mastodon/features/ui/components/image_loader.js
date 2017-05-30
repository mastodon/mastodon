import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';

import notFoundPng from '../../../../images/mastodon-not-found.png';

class ImageLoader extends ImmutablePureComponent {

  static propTypes = {
    src: PropTypes.string.isRequired,
  }

  state = {
    loading: true,
    error: false,
  }

  constructor(props) {
    super(props);
    this.loadImage(props.src);
  }

  componentWillReceiveProps(props) {
    this.loadImage(props.src);
  }

  loadImage(src) {
    const image = new Image();
    image.onerror = () => this.setState({loading: false, error: true});
    image.onload = () => this.setState({loading: false, error: false});
    image.src = src;
    this.lastSrc = src;
    this.setState({loading: true});
  }

  render() {
    const { src } = this.props;
    const { loading, error } = this.state;

    // TODO: handle image error state

    const imageClass = `image-loader__img ${loading ? 'image-loader__img-loading' : ''}`;

    return <img className={imageClass} src={src} />; // eslint-disable-line jsx-a11y/img-has-alt
  }

}

export default ImageLoader;
