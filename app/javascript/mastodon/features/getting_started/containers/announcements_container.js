import { connect } from 'react-redux';
import { fetchAnnouncements, dismissAnnouncement } from 'mastodon/actions/announcements';
import Announcements from '../components/announcements';

const mapStateToProps = state => ({
  announcements: state.getIn(['announcements', 'items']),
  domain: state.getIn(['meta', 'domain']),
});

const mapDispatchToProps = dispatch => ({
  fetchAnnouncements: () => dispatch(fetchAnnouncements()),
  dismissAnnouncement: id => dispatch(dismissAnnouncement(id)),
});

export default connect(mapStateToProps, mapDispatchToProps)(Announcements);
