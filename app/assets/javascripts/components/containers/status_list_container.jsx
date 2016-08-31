import { connect } from 'react-redux';
import StatusList  from '../components/status_list';

const mapStateToProps = function (state, props) {
  return {
    statuses: state.getIn(['timelines', props.type])
  };
};

export default connect(mapStateToProps)(StatusList);
