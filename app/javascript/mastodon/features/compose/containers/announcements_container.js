import { connect } from 'react-redux';
import Announcements from '../components/announcements';
import { toggleAnnouncements } from '../../../actions/announcements';

const mapStateToProps = (state) => ({
  visible: state.getIn(['announcements', 'visible']),
  announcements: state.getIn(['announcements', 'list']),
});

const mapDispatchToProps = (dispatch) => ({
  onToggle () {
    dispatch(toggleAnnouncements());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Announcements);
