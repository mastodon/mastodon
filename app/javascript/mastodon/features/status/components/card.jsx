import punycode from 'punycode';

import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';

import DescriptionIcon from '@/material-icons/400-24px/description-fill.svg?react';
import OpenInNewIcon from '@/material-icons/400-24px/open_in_new.svg?react';
import PlayArrowIcon from '@/material-icons/400-24px/play_arrow-fill.svg?react';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon }  from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import { useBlurhash } from 'mastodon/initial_state';

const IDNA_PREFIX = 'xn--';

const decodeIDNA = domain => {
  return domain
    .split('.')
    .map(part => part.indexOf(IDNA_PREFIX) === 0 ? punycode.decode(part.slice(IDNA_PREFIX.length)) : part)
    .join('.');
};

const getHostname = url => {
  const parser = document.createElement('a');
  parser.href = url;
  return parser.hostname;
};

const domParser = new DOMParser();

const addAutoPlay = html => {
  const document = domParser.parseFromString(html, 'text/html').documentElement;
  const iframe = document.querySelector('iframe');

  if (iframe) {
    if (iframe.src.indexOf('?') !== -1) {
      iframe.src += '&';
    } else {
      iframe.src += '?';
    }

    iframe.src += 'autoplay=1&auto_play=1';

    // DOM parser creates html/body elements around original HTML fragment,
    // so we need to get innerHTML out of the body and not the entire document
    return document.querySelector('body').innerHTML;
  }

  return html;
};

export default class Card extends PureComponent {

  static propTypes = {
    card: ImmutablePropTypes.map,
    onOpenMedia: PropTypes.func.isRequired,
    sensitive: PropTypes.bool,
  };

  state = {
    previewLoaded: false,
    embedded: false,
    revealed: !this.props.sensitive,
  };

  UNSAFE_componentWillReceiveProps (nextProps) {
    if (!Immutable.is(this.props.card, nextProps.card)) {
      this.setState({ embedded: false, previewLoaded: false });
    }

    if (this.props.sensitive !== nextProps.sensitive) {
      this.setState({ revealed: !nextProps.sensitive });
    }
  }

  componentDidMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
  }

  handleEmbedClick = () => {
    this.setState({ embedded: true });
  };

  handleExternalLinkClick = (e) => {
    e.stopPropagation();
  };

  setRef = c => {
    this.node = c;
  };

  handleImageLoad = () => {
    this.setState({ previewLoaded: true });
  };

  handleReveal = e => {
    e.preventDefault();
    e.stopPropagation();
    this.setState({ revealed: true });
  };

  renderVideo () {
    const { card } = this.props;
    const content = { __html: addAutoPlay(card.get('html')) };

    return (
      <div
        ref={this.setRef}
        className='status-card__image status-card-video'
        dangerouslySetInnerHTML={content}
        style={{ aspectRatio: '16 / 9' }}
      />
    );
  }

  render () {
    const { card } = this.props;
    const { embedded, revealed } = this.state;

    if (card === null) {
      return null;
    }

    const provider    = card.get('provider_name').length === 0 ? decodeIDNA(getHostname(card.get('url'))) : card.get('provider_name');
    const interactive = card.get('type') === 'video';
    const language    = card.get('language') || '';
    const largeImage  = (card.get('image')?.length > 0 && card.get('width') > card.get('height')) || interactive;

    const description = (
      <div className='status-card__content'>
        <span className='status-card__host'>
          <span lang={language}>{provider}</span>
          {card.get('published_at') && <> · <RelativeTimestamp timestamp={card.get('published_at')} /></>}
        </span>

        <strong className='status-card__title' title={card.get('title')} lang={language}>{card.get('title')}</strong>

        {card.get('author_name').length > 0 ? <span className='status-card__author'><FormattedMessage id='link_preview.author' defaultMessage='By {name}' values={{ name: <strong>{card.get('author_name')}</strong> }} /></span> : <span className='status-card__description' lang={language}>{card.get('description')}</span>}
      </div>
    );

    const thumbnailStyle = {
      visibility: revealed ? null : 'hidden',
    };

    if (largeImage && card.get('type') === 'video') {
      thumbnailStyle.aspectRatio = `16 / 9`;
    } else if (largeImage) {
      thumbnailStyle.aspectRatio = '1.91 / 1';
    } else {
      thumbnailStyle.aspectRatio = 1;
    }

    let embed;

    let canvas = (
      <Blurhash
        className={classNames('status-card__image-preview', {
          'status-card__image-preview--hidden': revealed && this.state.previewLoaded,
        })}
        hash={card.get('blurhash')}
        dummy={!useBlurhash}
      />
    );

    const thumbnailDescription = card.get('image_description');
    const thumbnail = <img src={card.get('image')} alt={thumbnailDescription} title={thumbnailDescription} lang={language} style={thumbnailStyle} onLoad={this.handleImageLoad} className='status-card__image-image' />;

    let spoilerButton = (
      <button type='button' onClick={this.handleReveal} className='spoiler-button__overlay'>
        <span className='spoiler-button__overlay__label'>
          <FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' />
          <span className='spoiler-button__overlay__action'><FormattedMessage id='status.media.show' defaultMessage='Click to show' /></span>
        </span>
      </button>
    );

    spoilerButton = (
      <div className={classNames('spoiler-button', { 'spoiler-button--minified': revealed })}>
        {spoilerButton}
      </div>
    );

    if (interactive) {
      if (embedded) {
        embed = this.renderVideo();
      } else {
        embed = (
          <div className='status-card__image'>
            {canvas}
            {thumbnail}

            {revealed ? (
              <div className='status-card__actions' onClick={this.handleEmbedClick} role='none'>
                <div>
                  <button type='button' onClick={this.handleEmbedClick}><Icon id='play' icon={PlayArrowIcon} /></button>
                  <a href={card.get('url')} onClick={this.handleExternalLinkClick} target='_blank' rel='noopener noreferrer'><Icon id='external-link' icon={OpenInNewIcon} /></a>
                </div>
              </div>
            ) : spoilerButton}
          </div>
        );
      }

      return (
        <div className={classNames('status-card', { expanded: largeImage })} ref={this.setRef} onClick={revealed ? null : this.handleReveal} role={revealed ? 'button' : null}>
          {embed}
          <a href={card.get('url')} target='_blank' rel='noopener noreferrer'>{description}</a>
        </div>
      );
    } else if (card.get('image')) {
      embed = (
        <div className='status-card__image'>
          {canvas}
          {thumbnail}
        </div>
      );
    } else {
      embed = (
        <div className='status-card__image'>
          <Icon id='file-text' icon={DescriptionIcon} />
        </div>
      );
    }

    return (
      <a href={card.get('url')} className={classNames('status-card', { expanded: largeImage })} target='_blank' rel='noopener noreferrer' ref={this.setRef}>
        {embed}
        {description}
      </a>
    );
  }

}
