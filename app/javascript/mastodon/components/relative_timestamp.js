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

@injectIntl
export default class RelativeTimestamp extends React.Component {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    timestamp: PropTypes.string.isRequired,
  };

  shouldComponentUpdate (nextProps) {
    // As of right now the locale doesn't change without a new page load,
    // but we might as well check in case that ever changes.
    return this.props.timestamp !== nextProps.timestamp ||
      this.props.intl.locale !== nextProps.intl.locale;
  }

  render () {
    const { timestamp, intl } = this.props;
    const date = new Date(timestamp);

    return (
      <time dateTime={timestamp} title={intl.formatDate(date, dateFormatOptions)}>
        <FormattedRelative value={date} />
      </time>
    );
  }

}
