import PropTypes from 'prop-types';
import React from 'react';

import classNames from 'classnames';

import { Blurhash } from './blurhash';


export default class Image extends React.PureComponent {

  static propTypes = {
    src: PropTypes.string,
    srcSet: PropTypes.string,
    blurhash: PropTypes.string,
    className: PropTypes.string,
  };

  state = {
    loaded: false,
  };

  handleLoad = () => this.setState({ loaded: true });

  render () {
    const { src, srcSet, blurhash, className } = this.props;
    const { loaded } = this.state;

    return (
      <div className={classNames('image', { loaded }, className)} role='presentation'>
        {blurhash && <Blurhash hash={blurhash} className='image__preview' />}
        <img src={src} srcSet={srcSet} alt='' onLoad={this.handleLoad} />
      </div>
    );
  }

}
