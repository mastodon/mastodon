import React from 'react';
import { injectIntl, FormattedRelative } from 'react-intl';
import PropTypes from 'prop-types';

const RelativeTimestamp = ({ intl, timestamp }) => {
  const date = new Date(timestamp);

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, { hour12: false, year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' })}>
      <FormattedRelative value={date} />
    </time>
  );
};

RelativeTimestamp.propTypes = {
  intl: PropTypes.object.isRequired,
  timestamp: PropTypes.string.isRequired,
};

export default injectIntl(RelativeTimestamp);
