import { connect } from 'react-redux';
import AutosuggestStatus from '../components/autosuggest_status';
import { makeGetStatus } from '../../../selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, { id }) => ({
    status: getStatus(state, id)
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(AutosuggestStatus);
