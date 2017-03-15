import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import { uploadCompose } from '../../../actions/compose';
import { createSelector } from 'reselect';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  insertEmojiCompose
} from '../../../actions/compose';

const getMentionedUsernames = createSelector(state => state.getIn(['compose', 'text']), text => text.match(/(?:^|[^\/\w])@([a-z0-9_]+@[a-z0-9\.\-]+)/ig));

const getMentionedDomains = createSelector(getMentionedUsernames, mentionedUsernamesWithDomains => {
  return mentionedUsernamesWithDomains !== null ? [...new Set(mentionedUsernamesWithDomains.map(item => item.split('@')[2]))] : [];
});

const mapStateToProps = (state, props) => {
  const mentionedUsernames = getMentionedUsernames(state);
  const mentionedUsernamesWithDomains = getMentionedDomains(state);

  return {
    text: state.getIn(['compose', 'text']),
    suggestion_token: state.getIn(['compose', 'suggestion_token']),
    suggestions: state.getIn(['compose', 'suggestions']),
    spoiler: state.getIn(['compose', 'spoiler']),
    spoiler_text: state.getIn(['compose', 'spoiler_text']),
    unlisted: state.getIn(['compose', 'unlisted'], ),
    private: state.getIn(['compose', 'private']),
    fileDropDate: state.getIn(['compose', 'fileDropDate']),
    focusDate: state.getIn(['compose', 'focusDate']),
    preselectDate: state.getIn(['compose', 'preselectDate']),
    is_submitting: state.getIn(['compose', 'is_submitting']),
    is_uploading: state.getIn(['compose', 'is_uploading']),
    me: state.getIn(['compose', 'me']),
    needsPrivacyWarning: state.getIn(['compose', 'private']) && mentionedUsernames !== null,
    mentionedDomains: mentionedUsernamesWithDomains
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

  onChangeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, data) {
    dispatch(insertEmojiCompose(position, data));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);
