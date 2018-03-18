import { connect } from 'react-redux';
import Card from '../components/card';

const mapStateToProps = (state, { statusId }) => ({
  card: state.cards.get(statusId, null),
});

export default connect(mapStateToProps)(Card);
