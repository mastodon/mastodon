import PropTypes from 'prop-types';

class CharacterCounter extends React.PureComponent {

  checkRemainingText (diff) {
    if (diff <= 0) {
      return <span className='character-counter character-counter--over'>{diff}</span>;
    }
    return <span className='character-counter'>{diff}</span>;
  }

  render () {
    const diff = this.props.max - this.props.text.replace(/[\uD800-\uDBFF][\uDC00-\uDFFF]/g, "_").length;

    return this.checkRemainingText(diff);
  }

}

CharacterCounter.propTypes = {
  text: PropTypes.string.isRequired,
  max: PropTypes.number.isRequired
}

export default CharacterCounter;
