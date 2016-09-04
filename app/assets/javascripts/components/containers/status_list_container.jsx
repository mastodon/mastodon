import { connect }           from 'react-redux';
import StatusList            from '../components/status_list';
import { replyCompose }      from '../actions/compose';
import { reblog, favourite } from '../actions/interactions';

function selectStatus(state, id) {
  let status = state.getIn(['timelines', 'statuses', id]);

  status = status.set('account', state.getIn(['timelines', 'accounts', status.get('account')]));

  if (status.get('reblog') !== null) {
    status = status.set('reblog', selectStatus(state, status.get('reblog')));
  }

  return status;
};

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
