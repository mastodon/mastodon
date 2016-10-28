import { connect }           from 'react-redux';
import SuggestionsBox        from '../components/suggestions_box';

const mapStateToProps = (state) => ({
  accountIds: state.get('suggestions')
});

export default connect(mapStateToProps)(SuggestionsBox);
