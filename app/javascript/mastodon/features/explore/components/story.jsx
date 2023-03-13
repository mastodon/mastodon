import React from 'react';
import PropTypes from 'prop-types';
import Blurhash from 'mastodon/components/blurhash';
import { accountsCountRenderer } from 'mastodon/components/hashtag';
import ShortNumber from 'mastodon/components/short_number';
import Skeleton from 'mastodon/components/skeleton';
import classNames from 'classnames';

export default class Story extends React.PureComponent {

  static propTypes = {
    url: PropTypes.string,
    title: PropTypes.string,
    publisher: PropTypes.string,
    sharedTimes: PropTypes.number,
    thumbnail: PropTypes.string,
    blurhash: PropTypes.string,
  };

  state = {
    thumbnailLoaded: false,
  };

  handleImageLoad = () => this.setState({ thumbnailLoaded: true });

  render () {
    const { url, title, publisher, sharedTimes, thumbnail, blurhash } = this.props;

    const { thumbnailLoaded } = this.state;

    return (
      <a className='story' href={url} target='blank' rel='noopener'>
        <div className='story__details'>
          <div className='story__details__publisher'>{publisher ? publisher : <Skeleton width={50} />}</div>
          <div className='story__details__title'>{title ? title : <Skeleton />}</div>
          <div className='story__details__shared'>{typeof sharedTimes === 'number' ? <ShortNumber value={sharedTimes} renderer={accountsCountRenderer} /> : <Skeleton width={100} />}</div>
        </div>

        <div className='story__thumbnail'>
          {thumbnail ? (
            <React.Fragment>
              <div className={classNames('story__thumbnail__preview', { 'story__thumbnail__preview--hidden': thumbnailLoaded })}><Blurhash hash={blurhash} /></div>
              <img src={thumbnail} onLoad={this.handleImageLoad} alt='' role='presentation' />
            </React.Fragment>
          ) : <Skeleton />}
        </div>
      </a>
    );
  }

}
