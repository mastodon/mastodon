import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import {
  changeCompose,
  submitCompose,
  cancelReplyCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSensitivity,
  changeComposeSpoilerness,
  changeComposeSpoilerText,
  changeComposeVisibility,
  changeComposeListability
} from '../../../actions/compose';
import { makeGetStatus } from '../../../selectors';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = function (state, props) {
    const mentionedUsernamesWithDomains = state.getIn(['compose', 'text']).match(/(?:^|[^\/\w])@([a-z0-9_]+@[a-z0-9\.\-]+)/ig);

    return {
      text: state.getIn(['compose', 'text']),
      suggestion_token: state.getIn(['compose', 'suggestion_token']),
      suggestions: state.getIn(['compose', 'suggestions']),
      sensitive: state.getIn(['compose', 'sensitive']),
      spoiler: state.getIn(['compose', 'spoiler']),
      spoiler_text: state.getIn(['compose', 'spoiler_text']),
      unlisted: state.getIn(['compose', 'unlisted'], ),
      private: state.getIn(['compose', 'private']),
      fileDropDate: state.getIn(['compose', 'fileDropDate']),
      is_submitting: state.getIn(['compose', 'is_submitting']),
      is_uploading: state.getIn(['compose', 'is_uploading']),
      in_reply_to: getStatus(state, state.getIn(['compose', 'in_reply_to'])),
      media_count: state.getIn(['compose', 'media_attachments']).size,
      me: state.getIn(['compose', 'me']),
      needsPrivacyWarning: state.getIn(['compose', 'private']) && mentionedUsernamesWithDomains !== null,
      mentionedDomains: mentionedUsernamesWithDomains !== null ? [...new Set(mentionedUsernamesWithDomains.map(item => item.split('@')[2]))] : []
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

    onSuggestionSelected (position, token, accountId) {
      dispatch(selectComposeSuggestion(position, token, accountId));
    },

    onChangeSensitivity (checked) {
      dispatch(changeComposeSensitivity(checked));
    },

    onChangeSpoilerness (checked) {
      dispatch(changeComposeSpoilerness(checked));
    },

    onChangeSpoilerText (checked) {
      dispatch(changeComposeSpoilerText(checked));
    },

    onChangeVisibility (checked) {
      dispatch(changeComposeVisibility(checked));
    },

    onChangeListability (checked) {
      dispatch(changeComposeListability(checked));
    }
  }
};

export default connect(makeMapStateToProps, mapDispatchToProps)(ComposeForm);
