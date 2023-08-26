import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { Blurhash } from 'mastodon/components/blurhash';
import { accountsCountRenderer } from 'mastodon/components/hashtag';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { ShortNumber } from 'mastodon/components/short_number';
import { Skeleton } from 'mastodon/components/skeleton';

export default class Story extends PureComponent {

  static propTypes = {
    url: PropTypes.string,
    title: PropTypes.string,
    lang: PropTypes.string,
    publisher: PropTypes.string,
    publishedAt: PropTypes.string,
    author: PropTypes.string,
    sharedTimes: PropTypes.number,
    thumbnail: PropTypes.string,
    thumbnailDescription: PropTypes.string,
    blurhash: PropTypes.string,
    expanded: PropTypes.bool,
  };

  state = {
    thumbnailLoaded: false,
  };

  handleImageLoad = () => this.setState({ thumbnailLoaded: true });

  render () {
    const { expanded, url, title, lang, publisher, author, publishedAt, sharedTimes, thumbnail, thumbnailDescription, blurhash } = this.props;

    const { thumbnailLoaded } = this.state;

    return (
      <a className={classNames('story', { expanded })} href={url} target='blank' rel='noopener'>
        <div className='story__details'>
          <div className='story__details__publisher'>{publisher ? <span lang={lang}>{publisher}</span> : <Skeleton width={50} />}{publishedAt && <> · <RelativeTimestamp timestamp={publishedAt} /></>}</div>
          <div className='story__details__title' lang={lang}>{title ? title : <Skeleton />}</div>
          <div className='story__details__shared'>{author && <><FormattedMessage id='link_preview.author' defaultMessage='By {name}' values={{ name: <strong>{author}</strong> }} /> · </>}{typeof sharedTimes === 'number' ? <ShortNumber value={sharedTimes} renderer={accountsCountRenderer} /> : <Skeleton width={100} />}</div>
        </div>

        <div className='story__thumbnail'>
          {thumbnail ? (
            <>
              <div className={classNames('story__thumbnail__preview', { 'story__thumbnail__preview--hidden': thumbnailLoaded })}><Blurhash hash={blurhash} /></div>
              <img src={thumbnail} onLoad={this.handleImageLoad} alt={thumbnailDescription} title={thumbnailDescription} lang={lang} />
            </>
          ) : <Skeleton />}
        </div>
      </a>
    );
  }

}
