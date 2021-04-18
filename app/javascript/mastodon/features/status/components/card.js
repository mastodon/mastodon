import React from 'react';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import punycode from 'punycode';
import classnames from 'classnames';
import Icon from 'mastodon/components/icon';

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

const trim = (text, len) => {
  const cut = text.indexOf(' ', len);

  if (cut === -1) {
    return text;
  }

  return text.substring(0, cut) + (text.length > len ? '…' : '');
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
    maxDescription: PropTypes.number,
    onOpenMedia: PropTypes.func.isRequired,
    compact: PropTypes.bool,
    defaultWidth: PropTypes.number,
    cacheWidth: PropTypes.func,
  };

  static defaultProps = {
    maxDescription: 50,
    compact: false,
  };

  state = {
    width: this.props.defaultWidth || 280,
    embedded: false,
  };

  componentWillReceiveProps (nextProps) {
    if (!Immutable.is(this.props.card, nextProps.card)) {
      this.setState({ embedded: false });
    }
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
      0
    );
  };

  handleEmbedClick = () => {
    const { card } = this.props;

    if (card.get('type') === 'photo') {
      this.handlePhotoClick();
    } else {
      this.setState({ embedded: true });
    }
  }

  setRef = c => {
    if (c) {
      if (this.props.cacheWidth) this.props.cacheWidth(c.offsetWidth);
      this.setState({ width: c.offsetWidth });
    }
  }

  renderVideo () {
    const { card }  = this.props;
    const content   = { __html: addAutoPlay(card.get('html')) };
    const { width } = this.state;
    const ratio     = card.get('width') / card.get('height');
    const height    = width / ratio;

    return (
      <div
        ref={this.setRef}
        className='status-card__image status-card-video'
        dangerouslySetInnerHTML={content}
        style={{ height }}
      />
    );
  }

  render () {
    const { card, maxDescription, compact } = this.props;
    const { width, embedded } = this.state;

    if (card === null) {
      return null;
    }

    const provider    = card.get('provider_name').length === 0 ? decodeIDNA(getHostname(card.get('url'))) : card.get('provider_name');
    const horizontal  = (!compact && card.get('width') > card.get('height') && (card.get('width') + 100 >= width)) || card.get('type') !== 'link' || embedded;
    const interactive = card.get('type') !== 'link';
    const className   = classnames('status-card', { horizontal, compact, interactive });
    const title       = interactive ? <a className='status-card__title' href={card.get('url')} title={card.get('title')} rel='noopener noreferrer' target='_blank'><strong>{card.get('title')}</strong></a> : <strong className='status-card__title' title={card.get('title')}>{card.get('title')}</strong>;
    const ratio       = card.get('width') / card.get('height');
    const height      = (compact && !embedded) ? (width / (16 / 9)) : (width / ratio);

    const description = (
      <div className='status-card__content'>
        {title}
        {!(horizontal || compact) && <p className='status-card__description'>{trim(card.get('description') || '', maxDescription)}</p>}
        <span className='status-card__host'>{provider}</span>
      </div>
    );

    let embed     = '';
    let thumbnail = <div style={{ backgroundImage: `url(${card.get('image')})`, width: horizontal ? width : null, height: horizontal ? height : null }} className='status-card__image-image' />;

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
            {thumbnail}

            <div className='status-card__actions'>
              <div>
                <button onClick={this.handleEmbedClick}><Icon id={iconVariant} /></button>
                {horizontal && <a href={card.get('url')} target='_blank' rel='noopener noreferrer'><Icon id='external-link' /></a>}
              </div>
            </div>
          </div>
        );
      }

      return (
        <div className={className} ref={this.setRef}>
          {embed}
          {!compact && description}
        </div>
      );
    } else if (card.get('image')) {
      embed = (
        <div className='status-card__image'>
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
