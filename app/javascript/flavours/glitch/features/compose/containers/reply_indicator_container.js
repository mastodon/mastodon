import { connect } from 'react-redux';
import { cancelReplyCompose } from 'flavours/glitch/actions/compose';
import { makeGetStatus } from 'flavours/glitch/selectors';
import ReplyIndicator from '../components/reply_indicator';

function makeMapStateToProps (state) {
  const inReplyTo = state.getIn(['compose', 'in_reply_to']);

  return {
    status: inReplyTo ? state.getIn(['statuses', inReplyTo]) : null,
  };
};

const mapDispatchToProps = dispatch => ({

  onCancel () {
    dispatch(cancelReplyCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(ReplyIndicator);
