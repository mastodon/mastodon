import { connect }   from 'react-redux';
import NavigationBar from '../components/navigation_bar';

const mapStateToProps = (state, props) => ({
  account: state.getIn(['timelines', 'accounts', state.getIn(['timelines', 'me'])])
});

export default connect(mapStateToProps)(NavigationBar);
