import { connect }           from 'react-redux';
import StatusList            from '../components/status_list';
import { replyCompose }      from '../actions/compose';
import { reblog, favourite } from '../actions/interactions';
import { selectStatus }      from '../reducers/timelines';

const mapStateToProps = function (state, props) {
  return {
    statuses: state.getIn(['timelines', props.type]).map(id => selectStatus(state, id))
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onReply: function (status) {
      dispatch(replyCompose(status));
    },

    onFavourite: function (status) {
      dispatch(favourite(status));
    },

    onReblog: function (status) {
      dispatch(reblog(status));
    }
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(StatusList);
