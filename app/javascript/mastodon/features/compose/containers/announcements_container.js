import { connect } from 'react-redux';
import Announcements from '../components/announcements';

const mapStateToProps = (state, props) => {
  return {
    homeSize: state.getIn(['timelines', 'home', 'items']).size,
    isLoading: state.getIn(['timelines', 'home', 'isLoading']),
  };
};

export default connect(mapStateToProps)(Announcements);
