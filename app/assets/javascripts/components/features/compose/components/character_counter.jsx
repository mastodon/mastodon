import PureRenderMixin from 'react-addons-pure-render-mixin';

const CharacterCounter = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    max: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  checkRemainingText (diff) {
    if (diff <= 0) {
      return <span style={{ fontSize: '16px', cursor: 'default', color: '#ff5050' }}>{diff}</span>;
    }
    return <span style={{ fontSize: '16px', cursor: 'default' }}>{diff}</span>;
  },

  render () {
    const diff = this.props.max - this.props.text.replace(/[\uD800-\uDBFF][\uDC00-\uDFFF]/g, "_").length;

    return this.checkRemainingText(diff);
  }

});

export default CharacterCounter;
