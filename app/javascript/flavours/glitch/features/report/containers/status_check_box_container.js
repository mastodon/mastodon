import { connect } from 'react-redux';
import StatusCheckBox from '../components/status_check_box';
import { makeGetStatus } from 'flavours/glitch/selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, { id }) => ({
    status: getStatus(state, { id }),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(StatusCheckBox);
