import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting } from '../../../actions/settings';
import { changeColumnParams } from '../../../actions/columns';

const mapStateToProps = (state, { columnId }) => {
  const uuid = columnId;
  const columns = state.getIn(['settings', 'columns']);
  const index = columns.findIndex(c => c.get('uuid') === uuid);

  return {
    settings: (uuid && index >= 0) ? columns.get(index).get('params') : state.getIn(['settings', 'public']),
  };
};

const mapDispatchToProps = (dispatch, { columnId }) => {
  return {
    onChange (key, checked) {
      if (columnId) {
        dispatch(changeColumnParams(columnId, key, checked));
      } else {
        dispatch(changeSetting(['public', ...key], checked));
      }

      // 絞り込み「リモートのみ」がONになった場合は、絞り込み「ローカルのみ」をOFF
      if (key[1] == 'onlyRemote' && checked) {
        console.log('this line');
        dispatch(changeSetting(['public', 'other', 'onlyLocal'], false));
      }

      // 絞り込み「ローカルのみ」がONになった場合は、絞り込み「リモートのみ」をOFF
      if (key[1] == 'onlyLocal' && checked) {
        console.log('this line');
        dispatch(changeSetting(['public', 'other', 'onlyRemote'], false));
      }
    },
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
