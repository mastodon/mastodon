import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import punycode from 'punycode';

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

const getProviderName =
  card => card.get('provider_name') || decodeIDNA(getHostname(card.get('url')));

export default class Card extends React.PureComponent {

  static propTypes = {
    card: ImmutablePropTypes.map,
  };

  renderLink () {
    const { card } = this.props;

    let image    = '';

    if (card.get('image')) {
      image = (
        <div className='status-card__image'>
          <img src={card.get('image')} alt={card.get('title')} className='status-card__image-image' />
        </div>
      );
    }

    return (
      <a href={card.get('url')} className='status-card' target='_blank' rel='noopener'>
        {image}

        <div className='status-card__content'>
          <div className='status-card__header'>
            <strong className='status-card__title' title={card.get('title')}>{card.get('title')}</strong>
          </div>
          <p className='status-card__description'>{(card.get('description') || '').substring(0, 50)}</p>
          <span className='status-card__host'>{getProviderName(card)}</span>
        </div>
      </a>
    );
  }

  renderPost () {
    const { card } = this.props;

    let image    = '';

    if (card.get('image')) {
      image = (
        <div className='status-card__image'>
          <img src={card.get('image')} alt={card.get('title')} className='status-card__image-image' />
        </div>
      );
    }

    return (
      <a href={card.get('url')} className='status-card' target='_blank' rel='noopener'>
        {image}

        <div className='status-card__content'>
          <div className='status-card__header'>
            <strong className='status-card__title'>{card.get('author_name')}</strong>
            <span className='status-card__author'>{card.get('title')}</span>
          </div>
          <p className='status-card__description'>{(card.get('description') || '').substring(0, 200)}</p>
          <span className='status-card__host'>{getProviderName(card)}</span>
        </div>
      </a>
    );
  }

  renderPhoto () {
    const { card } = this.props;

    return (
      <a href={card.get('url')} className='status-card-photo' target='_blank' rel='noopener'>
        <img src={card.get('url')} alt={card.get('title')} width={card.get('width')} height={card.get('height')} />
      </a>
    );
  }

  renderVideo () {
    const { card } = this.props;
    const content  = { __html: card.get('html') };

    return (
      <div
        className='status-card-video'
        dangerouslySetInnerHTML={content}
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
    case 'post':
      return this.renderPost();
    case 'rich':
    default:
      return null;
    }
  }

}
