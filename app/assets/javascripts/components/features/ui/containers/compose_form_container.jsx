import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import {
  changeCompose,
  submitCompose,
  cancelReplyCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions
} from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = function (state, props) {
    return {
      text: state.getIn(['compose', 'text']),
      suggestions: state.getIn(['compose', 'suggestions']),
      is_submitting: state.getIn(['compose', 'is_submitting']),
      is_uploading: state.getIn(['compose', 'is_uploading']),
      in_reply_to: getStatus(state, state.getIn(['compose', 'in_reply_to']))
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = function (dispatch) {
  return {
    onChange (text) {
      dispatch(changeCompose(text));
    },

    onSubmit () {
      dispatch(submitCompose());
    },

    onCancelReply () {
      dispatch(cancelReplyCompose());
    },

    onClearSuggestions () {
      dispatch(clearComposeSuggestions());
    },

    onFetchSuggestions (token) {
      dispatch(fetchComposeSuggestions(token));
    }
  }
};

export default connect(makeMapStateToProps, mapDispatchToProps)(ComposeForm);
