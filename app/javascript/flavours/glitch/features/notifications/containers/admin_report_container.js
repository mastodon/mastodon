import { connect } from 'react-redux';
import { makeGetReport } from 'flavours/glitch/selectors';
import AdminReport from '../components/admin_report';

const mapStateToProps = (state, { notification }) => {
  const getReport = makeGetReport();

  return {
    report: notification.get('report') ? getReport(state, notification.get('report'), notification.getIn(['report', 'target_account', 'id'])) : null,
  };
};

export default connect(mapStateToProps)(AdminReport);
