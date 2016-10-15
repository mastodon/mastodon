import { connect }           from 'react-redux';
import { getSuggestions }    from '../../../selectors';
import SuggestionsBox        from '../components/suggestions_box';

const mapStateToProps = (state) => ({
  accounts: getSuggestions(state)
});

export default connect(mapStateToProps)(SuggestionsBox);
