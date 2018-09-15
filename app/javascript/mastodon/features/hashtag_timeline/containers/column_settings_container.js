import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting, saveSettings } from '../../../actions/settings';
import { changeColumnParams } from '../../../actions/columns';

const mapStateToProps = (state, { columnId }) => {
  const columns = state.getIn(['settings', 'columns']);
  const index   = columns.findIndex(c => c.get('uuid') === columnId);

  if (!(columnId && index >= 0)) {
    console.log("column must be pinned to save changes to tags")
    return {}
  }

  return { settings: columns.get(index).get('params') };
};

const mapDispatchToProps = (dispatch, { columnId }) => ({
  onChange (key, value) {
    dispatch(changeColumnParams(columnId, key, value));
  },

  onSave () {
    dispatch(saveSettings());
  },

  onLoad (text) {
    return new Promise((resolve) => {
      resolve([{ value: '#hashtag', label: '#hashtag' }]) // TODO
    })
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
