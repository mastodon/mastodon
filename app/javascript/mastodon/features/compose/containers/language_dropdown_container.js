import { createSelector } from '@reduxjs/toolkit';
import { Map as ImmutableMap } from 'immutable';
import { connect } from 'react-redux';


import { changeComposeLanguage } from 'mastodon/actions/compose';

import LanguageDropdown from '../components/language_dropdown';

const getFrequentlyUsedLanguages = createSelector([
  state => state.getIn(['settings', 'frequentlyUsedLanguages'], ImmutableMap()),
], languageCounters => (
  languageCounters.keySeq()
    .sort((a, b) => languageCounters.get(a) - languageCounters.get(b))
    .reverse()
    .toArray()
));

const mapStateToProps = state => ({
  frequentlyUsedLanguages: getFrequentlyUsedLanguages(state),
  value: state.getIn(['compose', 'language']),
});

const mapDispatchToProps = dispatch => ({

  onChange (value) {
    dispatch(changeComposeLanguage(value));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(LanguageDropdown);
