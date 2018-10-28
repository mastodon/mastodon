import { connect } from 'react-redux';
import Card from '../components/card';

const mapStateToProps = (state, { statusId }) => ({
  card: state.getIn(['statuses', statusId, 'card'], null),
});

export default connect(mapStateToProps)(Card);
