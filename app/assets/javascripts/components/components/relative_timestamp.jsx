import moment          from 'moment';
import PureRenderMixin from 'react-addons-pure-render-mixin';

moment.updateLocale('en', {
  relativeTime : {
    future: "in %s",
    past:   "%s",
    s:  "%ds",
    m:  "1m",
    mm: "%dm",
    h:  "1h",
    hh: "%dh",
    d:  "1d",
    dd: "%dd",
    M:  "1mo",
    MM: "%dmo",
    y:  "1y",
    yy: "%dy"
  }
});

const RelativeTimestamp = React.createClass({

  getInitialState () {
    return {
      text: ''
    };
  },

  propTypes: {
    timestamp: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this._updateMomentText();
    this.interval = setInterval(this._updateMomentText, 6000);
  },

  componentWillUnmount () {
    clearInterval(this.interval);
  },

  _updateMomentText () {
    this.setState({ text: moment(this.props.timestamp).fromNow() });
  },

  render () {
    return (
      <span>
        {this.state.text}
      </span>
    );
  }

});

export default RelativeTimestamp;
