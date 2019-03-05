import { connect } from 'react-redux';
import PollButton from '../components/poll_button';
import { addPoll, removePoll } from '../../../actions/compose';

const mapStateToProps = state => ({
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 0),
  active: state.getIn(['compose', 'poll']) !== null,
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'poll'])) {
        dispatch(removePoll());
      } else {
        dispatch(addPoll());
      }
    });
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(PollButton);
