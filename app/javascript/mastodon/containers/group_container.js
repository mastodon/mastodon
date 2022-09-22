import { connect } from 'react-redux';
import Group from '../components/group';

const mapStateToProps = (state, { id }) => ({
  group: state.getIn(['groups', id]),
});

export default connect(mapStateToProps)(Group);
