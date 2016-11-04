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

  propTypes: {
    timestamp: React.PropTypes.string.isRequired,
    now: React.PropTypes.any
  },

  mixins: [PureRenderMixin],

  render () {
    const timestamp = moment(this.props.timestamp);
    const now       = this.props.now;

    let string = '';

    if (timestamp.isAfter(now)) {
      string = 'Just now';
    } else {
      string = timestamp.from(now);
    }

    return (
      <span>
        {string}
      </span>
    );
  }

});

export default RelativeTimestamp;
