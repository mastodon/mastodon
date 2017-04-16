import PropTypes from 'prop-types';

class CharacterCounter extends React.PureComponent {

  render () {
    const diff = this.props.max - this.props.text.replace(/[\uD800-\uDBFF][\uDC00-\uDFFF]/g, "_").length;

    return (
      <span style={{ fontSize: '16px', cursor: 'default' }}>
        {diff}
      </span>
    );
  }

}

CharacterCounter.propTypes = {
  text: PropTypes.string.isRequired,
  max: PropTypes.number.isRequired
}

export default CharacterCounter;
