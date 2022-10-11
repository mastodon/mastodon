import { connect }   from 'react-redux';
import NavigationBar from '../components/navigation_bar';
import { me } from 'flavours/glitch/initial_state';

const mapStateToProps = state => {
  return {
    account: state.getIn(['accounts', me]),
  };
};

export default connect(mapStateToProps)(NavigationBar);
