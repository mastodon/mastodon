import { connect } from 'react-redux';
import Announcements from '../components/announcements';
import { toggleAnnouncements } from '../../../actions/announcements';

const mapStateToProps = (state) => ({
  announcements: state.getIn(['announcements', 'list']),
  visible: state.getIn(['announcements', 'visible']),
});

const mapDispatchToProps = (dispatch) => ({
  onToggle () {
    dispatch(toggleAnnouncements());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Announcements);
