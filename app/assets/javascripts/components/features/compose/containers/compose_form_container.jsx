import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSensitivity,
  changeComposeSpoilerness,
  changeComposeSpoilerText,
  changeComposeVisibility,
  changeComposeListability
} from '../../../actions/compose';

const mapStateToProps = (state, props) => {
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
    focusDate: state.getIn(['compose', 'focusDate']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    is_submitting: state.getIn(['compose', 'is_submitting']),
    is_uploading: state.getIn(['compose', 'is_uploading']),
    media_count: state.getIn(['compose', 'media_attachments']).size,
    me: state.getIn(['compose', 'me']),
    needsPrivacyWarning: state.getIn(['compose', 'private']) && mentionedUsernamesWithDomains !== null,
    mentionedDomains: mentionedUsernamesWithDomains !== null ? [...new Set(mentionedUsernamesWithDomains.map(item => item.split('@')[2]))] : []
  };
};

const mapDispatchToProps = (dispatch) => ({

  onChange (text) {
    dispatch(changeCompose(text));
  },

  onSubmit () {
    dispatch(submitCompose());
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

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);
