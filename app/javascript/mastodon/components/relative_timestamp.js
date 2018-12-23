import React from 'react';
import { injectIntl, defineMessages } from 'react-intl';
import PropTypes from 'prop-types';

const messages = defineMessages({
  just_now: { id: 'relative_time.just_now', defaultMessage: 'now' },
  seconds: { id: 'relative_time.seconds', defaultMessage: '{number}s' },
  minutes: { id: 'relative_time.minutes', defaultMessage: '{number}m' },
  hours: { id: 'relative_time.hours', defaultMessage: '{number}h' },
  days: { id: 'relative_time.days', defaultMessage: '{number}d' },
});

const dateFormatOptions = {
  hour12: false,
  year: 'numeric',
  month: 'short',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
};

const shortDateFormatOptions = {
  month: 'numeric',
  day: 'numeric',
};

const SECOND = 1000;
const MINUTE = 1000 * 60;
const HOUR   = 1000 * 60 * 60;
const DAY    = 1000 * 60 * 60 * 24;

const MAX_DELAY = 2147483647;

const selectUnits = delta => {
  const absDelta = Math.abs(delta);

  if (absDelta < MINUTE) {
    return 'second';
  } else if (absDelta < HOUR) {
    return 'minute';
  } else if (absDelta < DAY) {
    return 'hour';
  }

  return 'day';
};

const getUnitDelay = units => {
  switch (units) {
  case 'second':
    return SECOND;
  case 'minute':
    return MINUTE;
  case 'hour':
    return HOUR;
  case 'day':
    return DAY;
  default:
    return MAX_DELAY;
  }
};

@injectIntl
export default class RelativeTimestamp extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    timestamp: PropTypes.string.isRequired,
  };

  state = {
    now: this.props.intl.now(),
  };

  shouldComponentUpdate (nextProps, nextState) {
    // As of right now the locale doesn't change without a new page load,
    // but we might as well check in case that ever changes.
    return this.props.timestamp !== nextProps.timestamp ||
      this.props.intl.locale !== nextProps.intl.locale ||
      this.state.now !== nextState.now;
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.timestamp !== nextProps.timestamp) {
      this.setState({ now: this.props.intl.now() });
    }
  }

  componentDidMount () {
    this._scheduleNextUpdate(this.props, this.state);
  }

  componentWillUpdate (nextProps, nextState) {
    this._scheduleNextUpdate(nextProps, nextState);
  }

  componentWillUnmount () {
    clearTimeout(this._timer);
  }

  _scheduleNextUpdate (props, state) {
    clearTimeout(this._timer);

    const { timestamp }  = props;
    const delta          = (new Date(timestamp)).getTime() - state.now;
    const unitDelay      = getUnitDelay(selectUnits(delta));
    const unitRemainder  = Math.abs(delta % unitDelay);
    const updateInterval = 1000 * 10;
    const delay          = delta < 0 ? Math.max(updateInterval, unitDelay - unitRemainder) : Math.max(updateInterval, unitRemainder);

    this._timer = setTimeout(() => {
      this.setState({ now: this.props.intl.now() });
    }, delay);
  }

  render () {
    const { timestamp, intl } = this.props;

    const date  = new Date(timestamp);
    const delta = this.state.now - date.getTime();

    let relativeTime;

    if (delta < 10 * SECOND) {
      relativeTime = intl.formatMessage(messages.just_now);
    } else if (delta < 3 * DAY) {
      if (delta < MINUTE) {
        relativeTime = intl.formatMessage(messages.seconds, { number: Math.floor(delta / SECOND) });
      } else if (delta < HOUR) {
        relativeTime = intl.formatMessage(messages.minutes, { number: Math.floor(delta / MINUTE) });
      } else if (delta < DAY) {
        relativeTime = intl.formatMessage(messages.hours, { number: Math.floor(delta / HOUR) });
      } else {
        relativeTime = intl.formatMessage(messages.days, { number: Math.floor(delta / DAY) });
      }
    } else {
      relativeTime = intl.formatDate(date, shortDateFormatOptions);
    }

    return (
      <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
        {relativeTime}
      </time>
    );
  }

}
