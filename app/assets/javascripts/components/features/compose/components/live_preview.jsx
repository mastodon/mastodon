import PropTypes from 'prop-types';
const loadScriptOnce = require('load-script-once');

class LivePreview extends React.PureComponent {

  componentDidUpdate() {
    const node  = ReactDOM.findDOMNode(this);
    if (MathJax != undefined) {
	  MathJax.Hub.Queue(["Typeset", MathJax.Hub, node]);
    }
  }
  
  render () {
    const text = this.props.text;
    return <div>{text}</div>
  }

}

LivePreview.propTypes = {
  text: PropTypes.string.isRequired,
}

export default LivePreview;
