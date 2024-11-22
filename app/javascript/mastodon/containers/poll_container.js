import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { openModal } from 'mastodon/actions/modal';
import { fetchPoll, vote } from 'mastodon/actions/polls';
import Poll from 'mastodon/components/poll';

const mapDispatchToProps = (dispatch, { pollId }) => ({
  refresh: debounce(
    () => {
      dispatch(fetchPoll(pollId));
    },
    1000,
    { leading: true },
  ),

  onVote (choices) {
    dispatch(vote(pollId, choices));
  },

  onInteractionModal (type, status) {
    dispatch(openModal({
      modalType: 'INTERACTION',
      modalProps: {
        type,
        accountId: status.getIn(['account', 'id']),
        url: status.get('uri'),
      },
    }));
  }
});

const mapStateToProps = (state, { pollId }) => ({
  poll: state.getIn(['polls', pollId]),
});

export default connect(mapStateToProps, mapDispatchToProps)(Poll);
