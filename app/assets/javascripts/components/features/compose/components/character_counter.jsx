import PropTypes from 'prop-types';
import { length } from 'stringz';

class CharacterCounter extends React.PureComponent {

  checkRemainingText (diff) {
    if (diff <= 0) {
      return <span className='character-counter character-counter--over'>{diff}</span>;
    }
    return <span className='character-counter'>{diff}</span>;
  }

  render () {
    const diff = this.props.max - length(this.props.text);

    return this.checkRemainingText(diff);
  }

}

CharacterCounter.propTypes = {
  text: PropTypes.string.isRequired,
  max: PropTypes.number.isRequired
}

export default CharacterCounter;
