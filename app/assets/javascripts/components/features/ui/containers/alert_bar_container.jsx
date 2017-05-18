import { connect } from 'react-redux';
import AlertBar from '../components/alert_bar';

const mapStateToProps = state => ({
  isEmailConfirmed: state.getIn(['meta', 'is_email_confirmed']),
});

export default connect(mapStateToProps)(AlertBar);
