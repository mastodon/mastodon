import { connect } from 'react-redux';
import { debounce } from 'lodash';

import Poll from 'mastodon/components/poll';
import { fetchPoll, vote } from 'mastodon/actions/polls';

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
});

const mapStateToProps = (state, { pollId }) => ({
  poll: state.getIn(['polls', pollId]),
});

export default connect(mapStateToProps, mapDispatchToProps)(Poll);
