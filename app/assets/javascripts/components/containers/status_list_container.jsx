import { connect }      from 'react-redux';
import StatusList       from '../components/status_list';
import { replyCompose } from '../actions/compose';

const mapStateToProps = function (state, props) {
  return {
    statuses: state.getIn(['timelines', props.type])
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onReply: function (status) {
      dispatch(replyCompose(status));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(StatusList);
