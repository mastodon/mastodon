import React from 'react';
import { injectIntl, defineMessages } from 'react-intl';
import PropTypes from 'prop-types';

const messages = defineMessages({
  today: { id: 'relative_time.today', defaultMessage: 'today' },
  just_now: { id: 'relative_time.just_now', defaultMessage: 'now' },
  just_now_full: { id: 'relative_time.full.just_now', defaultMessage: 'just now' },
  seconds: { id: 'relative_time.seconds', defaultMessage: '{number}s' },
  seconds_full: { id: 'relative_time.full.seconds', defaultMessage: '{number, plural, one {# second} other {# seconds}} ago' },
  minutes: { id: 'relative_time.minutes', defaultMessage: '{number}m' },
  minutes_full: { id: 'relative_time.full.minutes', defaultMessage: '{number, plural, one {# minute} other {# minutes}} ago' },
  hours: { id: 'relative_time.hours', defaultMessage: '{number}h' },
  hours_full: { id: 'relative_time.full.hours', defaultMessage: '{number, plural, one {# hour} other {# hours}} ago' },
  days: { id: 'relative_time.days', defaultMessage: '{number}d' },
  days_full: { id: 'relative_time.full.days', defaultMessage: '{number, plural, one {# day} other {# days}} ago' },
  moments_remaining: { id: 'time_remaining.moments', defaultMessage: 'Moments remaining' },
  seconds_remaining: { id: 'time_remaining.seconds', defaultMessage: '{number, plural, one {# second} other {# seconds}} left' },
  minutes_remaining: { id: 'time_remaining.minutes', defaultMessage: '{number, plural, one {# minute} other {# minutes}} left' },
  hours_remaining: { id: 'time_remaining.hours', defaultMessage: '{number, plural, one {# hour} other {# hours}} left' },
  days_remaining: { id: 'time_remaining.days', defaultMessage: '{number, plural, one {# day} other {# days}} left' },
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
  month: 'short',
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

export const timeAgoString = (intl, date, now, year, timeGiven, short) => {
  const delta = now - date.getTime();

  let relativeTime;

  if (delta < DAY && !timeGiven) {
    relativeTime = intl.formatMessage(messages.today);
  } else if (delta < 10 * SECOND) {
    relativeTime = intl.formatMessage(short ? messages.just_now : messages.just_now_full);
  } else if (delta < 7 * DAY) {
    if (delta < MINUTE) {
      relativeTime = intl.formatMessage(short ? messages.seconds : messages.seconds_full, { number: Math.floor(delta / SECOND) });
    } else if (delta < HOUR) {
      relativeTime = intl.formatMessage(short ? messages.minutes : messages.minutes_full, { number: Math.floor(delta / MINUTE) });
    } else if (delta < DAY) {
      relativeTime = intl.formatMessage(short ? messages.hours : messages.hours_full, { number: Math.floor(delta / HOUR) });
    } else {
      relativeTime = intl.formatMessage(short ? messages.days : messages.days_full, { number: Math.floor(delta / DAY) });
    }
  } else if (date.getFullYear() === year) {
    relativeTime = intl.formatDate(date, shortDateFormatOptions);
  } else {
    relativeTime = intl.formatDate(date, { ...shortDateFormatOptions, year: 'numeric' });
  }

  return relativeTime;
};

const timeRemainingString = (intl, date, now, timeGiven = true) => {
  const delta = date.getTime() - now;

  let relativeTime;

  if (delta < DAY && !timeGiven) {
    relativeTime = intl.formatMessage(messages.today);
  } else if (delta < 10 * SECOND) {
    relativeTime = intl.formatMessage(messages.moments_remaining);
  } else if (delta < MINUTE) {
    relativeTime = intl.formatMessage(messages.seconds_remaining, { number: Math.floor(delta / SECOND) });
  } else if (delta < HOUR) {
    relativeTime = intl.formatMessage(messages.minutes_remaining, { number: Math.floor(delta / MINUTE) });
  } else if (delta < DAY) {
    relativeTime = intl.formatMessage(messages.hours_remaining, { number: Math.floor(delta / HOUR) });
  } else {
    relativeTime = intl.formatMessage(messages.days_remaining, { number: Math.floor(delta / DAY) });
  }

  return relativeTime;
};

export default @injectIntl
class RelativeTimestamp extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    timestamp: PropTypes.string.isRequired,
    year: PropTypes.number.isRequired,
    futureDate: PropTypes.bool,
    short: PropTypes.bool,
  };

  state = {
    now: this.props.intl.now(),
  };

  static defaultProps = {
    year: (new Date()).getFullYear(),
    short: true,
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
    const { timestamp, intl, year, futureDate, short } = this.props;

    const timeGiven    = timestamp.includes('T');
    const date         = new Date(timestamp);
    const relativeTime = futureDate ? timeRemainingString(intl, date, this.state.now, timeGiven) : timeAgoString(intl, date, this.state.now, year, timeGiven, short);

    return (
      <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
        {relativeTime}
      </time>
    );
  }

}
