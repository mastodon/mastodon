import { connect }                                          from 'react-redux';
import ComposeForm                                          from '../components/compose_form';
import { changeCompose, submitCompose, cancelReplyCompose } from '../actions/compose';

function selectStatus(state) {
  let statusId = state.getIn(['compose', 'in_reply_to'], null);

  if (statusId === null) {
    return null;
  }

  let status = state.getIn(['timelines', 'statuses', statusId]);
  status = status.set('account', state.getIn(['timelines', 'accounts', status.get('account')]));

  return status;
};

const mapStateToProps = function (state, props) {
  return {
    text: state.getIn(['compose', 'text']),
    is_submitting: state.getIn(['compose', 'is_submitting']),
    in_reply_to: selectStatus(state)
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onChange: function (text) {
      dispatch(changeCompose(text));
    },

    onSubmit: function () {
      dispatch(submitCompose());
    },

    onCancelReply: function () {
      dispatch(cancelReplyCompose());
    }
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);
