import { connect } from 'react-redux';

import { makeGetStatus } from 'flavours/glitch/selectors';

import StatusCheckBox from '../components/status_check_box';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, { id }) => ({
    status: getStatus(state, { id }),
  });

  return mapStateToProps;
};

export default connect(makeMapStateToProps)(StatusCheckBox);
