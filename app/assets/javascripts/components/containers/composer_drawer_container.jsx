import { connect }                                          from 'react-redux';
import ComposerDrawer                                       from '../components/composer_drawer';
import { changeCompose, submitCompose, cancelReplyCompose } from '../actions/compose';

const mapStateToProps = function (state, props) {
  return {
    text: state.getIn(['compose', 'text']),
    is_submitting: state.getIn(['compose', 'is_submitting']),
    in_reply_to: state.getIn(['compose', 'in_reply_to'])
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

export default connect(mapStateToProps, mapDispatchToProps)(ComposerDrawer);
