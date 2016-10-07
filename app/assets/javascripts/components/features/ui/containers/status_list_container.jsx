import { connect }           from 'react-redux';
import StatusList            from '../../../components/status_list';
import { replyCompose }      from '../../../actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite
}                            from '../../../actions/interactions';
import { expandTimeline }    from '../../../actions/timelines';
import { makeGetTimeline }   from '../../../selectors';
import { deleteStatus }      from '../../../actions/statuses';

const makeMapStateToProps = () => {
  const getTimeline = makeGetTimeline();

  const mapStateToProps = (state, props) => ({
    statuses: getTimeline(state, props.type),
    me: state.getIn(['timelines', 'me'])
  });

  return mapStateToProps;
};

const mapDispatchToProps = function (dispatch, props) {
  return {
    onReply (status) {
      dispatch(replyCompose(status));
    },

    onFavourite (status) {
      if (status.get('favourited')) {
        dispatch(unfavourite(status));
      } else {
        dispatch(favourite(status));
      }
    },

    onReblog (status) {
      if (status.get('reblogged')) {
        dispatch(unreblog(status));
      } else {
        dispatch(reblog(status));
      }
    },

    onScrollToBottom () {
      dispatch(expandTimeline(props.type));
    },

    onDelete (status) {
      dispatch(deleteStatus(status.get('id')));
    }
  };
};

export default connect(makeMapStateToProps, mapDispatchToProps)(StatusList);
