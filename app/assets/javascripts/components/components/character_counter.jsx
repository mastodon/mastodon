const CharacterCounter = React.createClass({
  propTypes: {
    text: React.PropTypes.string.isRequired
  },

  render () {
    return (
      <span style={{ fontSize: '16px', cursor: 'default' }}>
        {this.props.text.length}
      </span>
    );
  }

});

export default CharacterCounter;
