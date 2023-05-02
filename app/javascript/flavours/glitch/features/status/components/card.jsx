import React from 'react';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import classnames from 'classnames';
import { decode as decodeIDNA } from 'flavours/glitch/utils/idna';
import Icon from 'flavours/glitch/components/icon';
import { useBlurhash } from 'flavours/glitch/initial_state';
import Blurhash from 'flavours/glitch/components/blurhash';

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

export default class Card extends React.PureComponent {

  static propTypes = {
    card: ImmutablePropTypes.map,
    onOpenMedia: PropTypes.func.isRequired,
    compact: PropTypes.bool,
    sensitive: PropTypes.bool,
  };

  static defaultProps = {
    compact: false,
  };

  state = {
    previewLoaded: false,
    embedded: false,
    revealed: !this.props.sensitive,
  };

  componentWillReceiveProps (nextProps) {
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

  handlePhotoClick = () => {
    const { card, onOpenMedia } = this.props;

    onOpenMedia(
      Immutable.fromJS([
        {
          type: 'image',
          url: card.get('embed_url'),
          description: card.get('title'),
          meta: {
            original: {
              width: card.get('width'),
              height: card.get('height'),
            },
          },
        },
      ]),
      0,
    );
  };

  handleEmbedClick = () => {
    const { card } = this.props;

    if (card.get('type') === 'photo') {
      this.handlePhotoClick();
    } else {
      this.setState({ embedded: true });
    }
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
    const { card }  = this.props;
    const content   = { __html: addAutoPlay(card.get('html')) };

    return (
      <div
        ref={this.setRef}
        className='status-card__image status-card-video'
        dangerouslySetInnerHTML={content}
        style={{ aspectRatio: `${card.get('width')} / ${card.get('height')}` }}
      />
    );
  }

  render () {
    const { card, compact } = this.props;
    const { embedded, revealed } = this.state;

    if (card === null) {
      return null;
    }

    const provider    = card.get('provider_name').length === 0 ? decodeIDNA(getHostname(card.get('url'))) : card.get('provider_name');
    const horizontal  = (!compact && card.get('width') > card.get('height')) || card.get('type') !== 'link' || embedded;
    const interactive = card.get('type') !== 'link';
    const className   = classnames('status-card', { horizontal, compact, interactive });
    const title       = interactive ? <a className='status-card__title' href={card.get('url')} title={card.get('title')} rel='noopener noreferrer' target='_blank'><strong>{card.get('title')}</strong></a> : <strong className='status-card__title' title={card.get('title')}>{card.get('title')}</strong>;
    const language    = card.get('language') || '';

    const description = (
      <div className='status-card__content' lang={language}>
        {title}
        {!(horizontal || compact) && <p className='status-card__description' title={card.get('description')}>{card.get('description')}</p>}
        <span className='status-card__host'>{provider}</span>
      </div>
    );

    const thumbnailStyle = {
      visibility: revealed? null : 'hidden',
    };

    if (horizontal) {
      thumbnailStyle.aspectRatio = (compact && !embedded) ? '16 / 9' : `${card.get('width')} / ${card.get('height')}`;
    }

    let embed     = '';
    let canvas = (
      <Blurhash
        className={classnames('status-card__image-preview', {
          'status-card__image-preview--hidden': revealed && this.state.previewLoaded,
        })}
        hash={card.get('blurhash')}
        dummy={!useBlurhash}
      />
    );
    let thumbnail = <img src={card.get('image')} alt='' style={thumbnailStyle} onLoad={this.handleImageLoad} className='status-card__image-image' />;
    let spoilerButton = (
      <button type='button' onClick={this.handleReveal} className='spoiler-button__overlay'>
        <span className='spoiler-button__overlay__label'><FormattedMessage id='status.sensitive_warning' defaultMessage='Sensitive content' /></span>
      </button>
    );
    spoilerButton = (
      <div className={classnames('spoiler-button', { 'spoiler-button--minified': revealed })}>
        {spoilerButton}
      </div>
    );

    if (interactive) {
      if (embedded) {
        embed = this.renderVideo();
      } else {
        let iconVariant = 'play';

        if (card.get('type') === 'photo') {
          iconVariant = 'search-plus';
        }

        embed = (
          <div className='status-card__image'>
            {canvas}
            {thumbnail}

            {revealed && (
              <div className='status-card__actions'>
                <div>
                  <button onClick={this.handleEmbedClick}><Icon id={iconVariant} /></button>
                  {horizontal && <a href={card.get('url')} target='_blank' rel='noopener noreferrer'><Icon id='external-link' /></a>}
                </div>
              </div>
            )}
            {!revealed && spoilerButton}
          </div>
        );
      }

      return (
        <div className={className} ref={this.setRef} onClick={revealed ? null : this.handleReveal} role={revealed ? 'button' : null}>
          {embed}
          {!compact && description}
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
          <Icon id='file-text' />
        </div>
      );
    }

    return (
      <a href={card.get('url')} className={className} target='_blank' rel='noopener noreferrer' ref={this.setRef}>
        {embed}
        {description}
      </a>
    );
  }

}
