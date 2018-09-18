import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { saveSettings } from '../../../actions/settings';
import { changeColumnParams } from '../../../actions/columns';
import api from '../../../api';

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

  onLoad (value) {
    return api().get('/api/v2/search', { params: { q: value } }).then(response => {
      return (response.data.hashtags || []).map((tag) => {
        return { value: `#${tag.name}`, label: `#${tag.name}` }
      })
    })
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
