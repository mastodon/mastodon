import { connect }   from 'react-redux';
import NavigationBar from '../components/navigation_bar';

const mapStateToProps = state => {
  return {
    account: state.getIn(['accounts', state.getIn(['meta', 'me'])]),
  };
};

export default connect(mapStateToProps)(NavigationBar);
