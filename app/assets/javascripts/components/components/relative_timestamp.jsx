import {
  FormattedMessage,
  FormattedDate,
  FormattedRelative
} from 'react-intl';

const RelativeTimestamp = ({ timestamp, now }) => {
  const diff = (new Date(now)) - (new Date(timestamp));

  if (diff < 0) {
    return <FormattedMessage id='relative_time.just_now' defaultMessage='Just now' />
  } else if (diff > (3600 * 24 * 7 * 1000)) {
    return <FormattedDate value={timestamp} />
  } else {
    return <FormattedRelative value={timestamp} initialNow={now} updateInterval={0} />
  }
};

RelativeTimestamp.propTypes = {
  timestamp: React.PropTypes.string.isRequired,
  now: React.PropTypes.any
};

export default RelativeTimestamp;
