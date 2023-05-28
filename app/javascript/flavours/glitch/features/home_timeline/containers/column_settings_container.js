import { connect } from 'react-redux';

import { changeSetting, saveSettings } from 'flavours/glitch/actions/settings';

import ColumnSettings from '../components/column_settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'home']),
});

const mapDispatchToProps = dispatch => ({

  onChange (path, checked) {
    dispatch(changeSetting(['home', ...path], checked));
  },

  onSave () {
    dispatch(saveSettings());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
