import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeNotificationsSetting } from '../../../actions/notifications';

const mapStateToProps = state => ({
  settings: state.getIn(['notifications', 'settings'])
});

const mapDispatchToProps = dispatch => ({

  onChange (key, checked) {
    dispatch(changeNotificationsSetting(key, checked));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
