import PropTypes from 'prop-types';

class CharacterCounter extends React.PureComponent {

  checkRemainingText (diff) {
    if (diff <= 0) {
      return <span style={{ fontSize: '16px', cursor: 'default', color: '#ff5050' }}>{diff}</span>;
    }
    return <span style={{ fontSize: '16px', cursor: 'default' }}>{diff}</span>;
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
