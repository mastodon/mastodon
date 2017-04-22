import ImmutablePropTypes from 'react-immutable-proptypes';

const contentStyle = {
  flex: '1 1 auto',
  padding: '8px',
  paddingLeft: '14px',
  overflow: 'hidden'
};

const imageStyle = {
  display: 'block',
  width: '100%',
  height: 'auto',
  margin: '0',
  borderRadius: '4px 0 0 4px'
};

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
          <img src={card.get('image')} alt={card.get('title')} style={imageStyle} />
        </div>
      );
    }

    return (
      <a href={card.get('url')} className='status-card' target='_blank' rel='noopener'>
        {image}

        <div className='status-card__content' style={contentStyle}>
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
