import { connect } from 'react-redux';
import PrivateToggle from '../components/private_toggle';
import { changeComposeVisibility } from '../../../actions/compose';

const mapStateToProps = state => ({
  isPrivate: state.getIn(['compose', 'private'])
});

const mapDispatchToProps = dispatch => ({

  onChange (e) {
    dispatch(changeComposeVisibility(e.target.checked));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(PrivateToggle);
