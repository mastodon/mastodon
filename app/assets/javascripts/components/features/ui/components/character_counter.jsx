import PureRenderMixin from 'react-addons-pure-render-mixin';

const CharacterCounter = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <span style={{ fontSize: '16px', cursor: 'default' }}>
        {this.props.text.length}
      </span>
    );
  }

});

export default CharacterCounter;
