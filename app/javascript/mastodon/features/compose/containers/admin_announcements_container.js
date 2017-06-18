import { connect } from 'react-redux';
import AdminAnnouncements from '../components/admin_announcements';

const mapStateToProps = (state, props) => {
  return {
    settings: state.getIn(['meta', 'admin_announcement']),
  };
};

export default connect(mapStateToProps)(AdminAnnouncements);
