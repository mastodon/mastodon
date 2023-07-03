import { connect } from 'react-redux';

import { changeSetting, saveSettings } from '../../../actions/settings';
import ColumnSettings from '../components/column_settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'home']),
});

const mapDispatchToProps = dispatch => ({

  onChange (key, checked) {
    dispatch(changeSetting(['home', ...key], checked));
  },

  onSave () {
    dispatch(saveSettings());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
