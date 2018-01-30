import React from 'react';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import punycode from 'punycode';
import classnames from 'classnames';

const IDNA_PREFIX = 'xn--';
let id = 0;

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

export default class Card extends React.PureComponent {

  static propTypes = {
    card: ImmutablePropTypes.map,
    maxDescription: PropTypes.number,
    onOpenMedia: PropTypes.func.isRequired,
  };

  static defaultProps = {
    maxDescription: 50,
  };

  state = {
    height: 0,
    width: 0,
  };

  componentWillUnmount () {
    removeEventListener('message', this.handleHtmlMessage);
  }

  handleHtmlLoad = ({ target }) => {
    this.id = id;
    id++;

    addEventListener('message', this.handleHtmlMessage);

    target.contentWindow.postMessage({
      type: 'mastodonSetHeight',
      id: this.id,
    }, '*');
  }

  handleHtmlMessage = ({ data }) => {
    if (data.id === this.id && data.type === 'mastodonSetHeight') {
      this.setState({ height: data.height });
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

  renderLink () {
    const { card, maxDescription } = this.props;
    const { width }  = this.state;
    const horizontal = card.get('width') > card.get('height') && (card.get('width') + 100 >= width);

    let image    = '';
    let provider = card.get('provider_name');

    if (card.get('image')) {
      image = (
        <div className='status-card__image'>
          <img src={card.get('image')} alt={card.get('title')} className='status-card__image-image' width={card.get('width')} height={card.get('height')} />
        </div>
      );
    }

    if (provider.length < 1) {
      provider = decodeIDNA(getHostname(card.get('url')));
    }

    const className = classnames('status-card', { horizontal });

    return (
      <a href={card.get('url')} className={className} target='_blank' rel='noopener' ref={this.setRef}>
        {image}

        <div className='status-card__content'>
          <strong className='status-card__title' title={card.get('title')}>{card.get('title')}</strong>
          {!horizontal && <p className='status-card__description'>{(card.get('description') || '').substring(0, maxDescription)}</p>}
          <span className='status-card__host'>{provider}</span>
        </div>
      </a>
    );
  }

  renderPhoto () {
    const { card } = this.props;

    return (
      <img
        className='status-card-photo'
        onClick={this.handlePhotoClick}
        role='button'
        tabIndex='0'
        src={card.get('embed_url')}
        alt={card.get('title')}
        width={card.get('width')}
        height={card.get('height')}
      />
    );
  }

  setRef = c => {
    if (c) {
      this.setState({ width: c.offsetWidth });
    }
  }

  renderHtml () {
    const { card }  = this.props;
    const encodedHtml = encodeURIComponent(card.get('unsafe_html'));
    const cardWidth = card.get('width');
    const cardHeight = card.get('height');
    const title = card.get('title')
      || card.get('description')
      || card.get('provider_name')
      || card.get('url');

    if (cardWidth > 0 && cardHeight > 0) {
      const { width } = this.state;
      const ratio  = cardWidth / cardHeight;
      const height = cardWidth > cardHeight ? (width / ratio) : (width * ratio);

      return (
        <iframe
          allowFullScreen
          className='status-card-html'
          src={'data:text/html;charset=UTF-8,%3Cstyle%3Ebody%7Bmargin:0%7Diframe%7Bwidth:100%25;height:100%25%7D%3C/style%3E' + encodedHtml}
          title={title}
          width={width}
          height={height}
        />
      );
    }

    const { height, width } = this.state;

    return (
      <iframe
        allowFullScreen
        className='status-card-html'
        onLoad={this.handleHtmlLoad}
        src={'data:text/html;charset=UTF-8,%3Cscript%3EaddEventListener(\'message\',function(e){var d=e.data;var t=9;function f(){e.source.postMessage({type:\'mastodonSetHeight\',id:d.id,height:document.getElementsByTagName(\'html\')[0].scrollHeight},\'*\')}function g(){f();setTimeout(g,t);t*=9}d&&d.type==\'mastodonSetHeight\'&&document.readyState==\'complete\'?g():addEventListener(\'DOMContentLoaded\',g)})%3C/script%3E%3Cstyle%3Ebody%7Bmargin:0%7D%3C/style%3E' + encodedHtml}
        title={title}
        width={width}
        height={height}
      />
    );
  }

  render () {
    const { card } = this.props;

    if (card === null) {
      return null;
    }

    switch(card.get('type')) {
    case 'link':
      return this.renderLink();
    case 'photo':
      return this.renderPhoto();
    case 'video':
    case 'rich':
      return this.renderHtml();
    default:
      return null;
    }
  }

}
