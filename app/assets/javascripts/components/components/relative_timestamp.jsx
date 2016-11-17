import {
  FormattedMessage,
  FormattedDate,
  FormattedRelative
} from 'react-intl';

const RelativeTimestamp = ({ timestamp }) => {
  return <FormattedRelative value={new Date(timestamp)} />;
};

RelativeTimestamp.propTypes = {
  timestamp: React.PropTypes.string.isRequired
};

export default RelativeTimestamp;
