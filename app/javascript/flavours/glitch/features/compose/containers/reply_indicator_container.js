import { connect } from 'react-redux';

import { cancelReplyCompose } from 'flavours/glitch/actions/compose';

import ReplyIndicator from '../components/reply_indicator';

const makeMapStateToProps = () => {
  const mapStateToProps = state => {
    let statusId = state.getIn(['compose', 'id'], null);
    let editing  = true;

    if (statusId === null) {
      statusId = state.getIn(['compose', 'in_reply_to']);
      editing  = false;
    }

    return {
      status: state.getIn(['statuses', statusId]),
      editing,
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = dispatch => ({

  onCancel () {
    dispatch(cancelReplyCompose());
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(ReplyIndicator);
