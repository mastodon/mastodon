import { connect } from 'react-redux';
import LanguageDropdown from '../components/language_dropdown';
import { changeComposeLanguage } from 'flavours/glitch/actions/compose';
import { useLanguage } from 'flavours/glitch/actions/languages';
import { createSelector } from 'reselect';
import { Map as ImmutableMap } from 'immutable';

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

  onClose (value) {
    dispatch(useLanguage(value));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(LanguageDropdown);
