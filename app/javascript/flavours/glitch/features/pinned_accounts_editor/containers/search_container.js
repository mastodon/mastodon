import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import {
  fetchPinnedAccountsSuggestions,
  clearPinnedAccountsSuggestions,
  changePinnedAccountsSuggestions,
} from '../../../actions/accounts';
import Search from 'flavours/glitch/features/list_editor/components/search';

const mapStateToProps = state => ({
  value: state.getIn(['pinnedAccountsEditor', 'suggestions', 'value']),
});

const mapDispatchToProps = dispatch => ({
  onSubmit: value => dispatch(fetchPinnedAccountsSuggestions(value)),
  onClear: () => dispatch(clearPinnedAccountsSuggestions()),
  onChange: value => dispatch(changePinnedAccountsSuggestions(value)),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(Search));
