import { connect } from 'react-redux';
import PollForm from '../components/poll_form';
import { addPollOption, removePollOption, changePollOption, changePollSettings } from '../../../actions/compose';

const mapStateToProps = state => ({
  options: state.getIn(['compose', 'poll', 'options']),
  expiresIn: state.getIn(['compose', 'poll', 'expires_in']),
  isMultiple: state.getIn(['compose', 'poll', 'multiple']),
});

const mapDispatchToProps = dispatch => ({
  onAddOption(title) {
    dispatch(addPollOption(title));
  },

  onRemoveOption(index) {
    dispatch(removePollOption(index));
  },

  onChangeOption(index, title) {
    dispatch(changePollOption(index, title));
  },

  onChangeSettings(expiresIn, isMultiple) {
    dispatch(changePollSettings(expiresIn, isMultiple));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(PollForm);
