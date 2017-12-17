import React from 'react';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import punycode from 'punycode';
import classnames from 'classnames';

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
    width: 0,
  };

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

  renderVideo () {
    const { card }  = this.props;
    const content   = { __html: card.get('html') };
    const { width } = this.state;
    const ratio     = card.get('width') / card.get('height');
    const height    = card.get('width') > card.get('height') ? (width / ratio) : (width * ratio);

    return (
      <div
        ref={this.setRef}
        className='status-card-video'
        dangerouslySetInnerHTML={content}
        style={{ height }}
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
      return this.renderVideo();
    case 'rich':
    default:
      return null;
    }
  }

}
