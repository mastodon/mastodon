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

    let url = card.get('url');
    let ytMatch = url.match(/http(?:s|):\/\/(?:www\.|)youtu(?:\.be\/|be\.com\/watch\?v=)([A-z0-9_-]{11})/);

    if(ytMatch){
      return (
        <iframe src={'https://youtube.com/embed/' + ytMatch[1]} title="YouTube Video" className='status-embed status-embed-youtube'/>
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
