import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import Search from 'flavours/glitch/features/list_editor/components/search';

import {
  fetchPinnedAccountsSuggestions,
  clearPinnedAccountsSuggestions,
  changePinnedAccountsSuggestions,
} from '../../../actions/accounts';


const mapStateToProps = state => ({
  value: state.getIn(['pinnedAccountsEditor', 'suggestions', 'value']),
});

const mapDispatchToProps = dispatch => ({
  onSubmit: value => dispatch(fetchPinnedAccountsSuggestions(value)),
  onClear: () => dispatch(clearPinnedAccountsSuggestions()),
  onChange: value => dispatch(changePinnedAccountsSuggestions(value)),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Search));
