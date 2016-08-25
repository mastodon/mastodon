import moment from 'moment';

moment.updateLocale('en', {
  relativeTime : {
    future: "in %s",
    past:   "%s ago",
    s:  "s",
    m:  "a minute",
    mm: "%dm",
    h:  "an hour",
    hh: "%dh",
    d:  "a day",
    dd: "%dd",
    M:  "a month",
    MM: "%dmo",
    y:  "a year",
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
      <span style={{ color: '#616b86' }}>
        {this.state.text}
      </span>
    );
  }

});

export default RelativeTimestamp;
