import React from 'react';
import { injectIntl, FormattedRelative } from 'react-intl';
import PropTypes from 'prop-types';

const dateFormatOptions = {
  hour12: false,
  year: 'numeric',
  month: 'short',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
};

class SelectiveTimestamp extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    timestamp: PropTypes.string.isRequired,
    absoluteTime: PropTypes.bool,
  };

  shouldComponentUpdate (nextProps) {
    // As of right now the locale doesn't change without a new page load,
    // but we might as well check in case that ever changes.
    return this.props.timestamp !== nextProps.timestamp ||
      this.props.intl.locale !== nextProps.intl.locale;
  }

  render () {
    const { timestamp, intl, absoluteTime } = this.props;
    const date = new Date(timestamp);
    const now = new Date();
    let shortFormatOptions = {
      hour12: false,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    };
    if (date.getFullYear() == now.getFullYear() && date.getMonth() == now.getMonth() && date.getDate() == now.getDate()) {
      delete shortFormatOptions['month'];
      delete shortFormatOptions['day'];
    }
    if (date.getFullYear() == now.getFullYear()) {
      delete shortFormatOptions['year'];
    }

    if (absoluteTime) {
      return (
        <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
          <span>{intl.formatDate(date, shortFormatOptions)}</span>
        </time>
      );
    }

    return (
      <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
        <FormattedRelative value={date} />
      </time>
    );
  }

}

export default injectIntl(SelectiveTimestamp);
