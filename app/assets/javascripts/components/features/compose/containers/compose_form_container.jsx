import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import {
  changeCompose,
  submitCompose,
  cancelReplyCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSensitivity
} from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = function (state, props) {
    return {
      text: state.getIn(['compose', 'text']),
      suggestion_token: state.getIn(['compose', 'suggestion_token']),
      suggestions: state.getIn(['compose', 'suggestions']).toJS(),
      sensitive: state.getIn(['compose', 'sensitive']),
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
    },

    onSuggestionSelected (position, accountId) {
      dispatch(selectComposeSuggestion(position, accountId));
    },

    onChangeSensitivity (checked) {
      dispatch(changeComposeSensitivity(checked));
    }
  }
};

export default connect(makeMapStateToProps, mapDispatchToProps)(ComposeForm);
