import { connect }       from 'react-redux';
import Status            from '../components/status';
import { makeGetStatus } from '../selectors';
import {
  replyCompose,
  mentionCompose
}                        from '../actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite
}                        from '../actions/interactions';
import { deleteStatus }  from '../actions/statuses';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, props.id),
    me: state.getIn(['timelines', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({

  onReply (status) {
    dispatch(replyCompose(status));
  },

  onReblog (status) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status));
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
  },

  onDelete (status) {
    dispatch(deleteStatus(status.get('id')));
  },

  onMention (account) {
    dispatch(mentionCompose(account));
  }

});

export default connect(makeMapStateToProps, mapDispatchToProps)(Status);
