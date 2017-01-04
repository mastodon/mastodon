import { injectIntl, FormattedRelative } from 'react-intl';

const RelativeTimestamp = ({ intl, timestamp }) => {
  const date = new Date(timestamp);

  return (
    <time dateTime={timestamp} title={intl.formatDate(date, { hour12: false, year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' })}>
      <FormattedRelative value={date} />
    </time>
  );
};

RelativeTimestamp.propTypes = {
  intl: React.PropTypes.object.isRequired,
  timestamp: React.PropTypes.string.isRequired
};

export default injectIntl(RelativeTimestamp);
