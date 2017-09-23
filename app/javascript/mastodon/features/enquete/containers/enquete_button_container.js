import { connect } from 'react-redux';
import EnqueteButton from '../components/enquete_button';
import { changeComposeEnquete } from '../../../actions/enquetes';

const mapStateToProps = state => ({
  active: state.getIn(['enquetes', 'active']),
});

const mapDispatchToProps = dispatch => ({
  onClick () {
    dispatch(changeComposeEnquete());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(EnqueteButton);
