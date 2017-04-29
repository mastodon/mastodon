import ImmutablePropTypes from 'react-immutable-proptypes';

const hostStyle = {
  display: 'block',
  marginTop: '5px',
  fontSize: '13px'
};

const getHostname = url => {
  const parser = document.createElement('a');
  parser.href = url;
  return parser.hostname;
};

class Card extends React.PureComponent {

  render () {
    const { card } = this.props;

    if (card === null) {
      return null;
    }

    let image = '';

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
          <strong className='status-card__title' title={card.get('title')}>{card.get('title')}</strong>
          <p className='status-card__description'>{card.get('description').substring(0, 50)}</p>
          <span className='status-card__host' style={hostStyle}>{getHostname(card.get('url'))}</span>
        </div>
      </a>
    );
  }
}

Card.propTypes = {
  card: ImmutablePropTypes.map
};

export default Card;
