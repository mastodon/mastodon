import { connect } from 'react-redux';
import EnqueteInputs from '../components/enquete_inputs';
import { changeComposeEnqueteText, changeConposeEnqueteDuration } from '../../../actions/enquetes';
import { submitCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  active: state.getIn(['enquetes', 'active']),
  items:  state.getIn(['enquetes', 'items']),
  duration: state.getIn(['enquetes', 'duration']),
});

const mapDispatchToProps = dispatch => ({
  onChangeEnqueteText(text, index){
    dispatch(changeComposeEnqueteText(text, index));
  },
  onChangeEnqueteDuration(duration){
    dispatch(changeConposeEnqueteDuration(duration));
  },
  onSubmit() {
    dispatch(submitCompose());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(EnqueteInputs);
