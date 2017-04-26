import { FormattedMessage } from 'react-intl';
import DisplayName from '../../../components/display_name';
import ImmutablePropTypes from 'react-immutable-proptypes';

const AutosuggestStatus = ({ status }) => (
  <div className='autosuggest-status'>
    <FormattedMessage id='search.status_by' defaultMessage='Status by {name}' values={{ name: <strong>@{status.getIn(['account', 'acct'])}</strong> }} />
  </div>
);

AutosuggestStatus.propTypes = {
  status: ImmutablePropTypes.map.isRequired
};

export default AutosuggestStatus;
