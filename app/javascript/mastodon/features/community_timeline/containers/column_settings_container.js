import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting } from '../../../actions/settings';
import { changeColumnParams } from '../../../actions/columns';

const mapStateToProps = (state, ownProps) => {
  const uuid = ownProps["columnId"];
  const columns = state.getIn(['settings', 'columns']);
  const index = columns.findIndex(c => c.get('uuid') == uuid);

  return {
    settings: (uuid && index >= 0) ? columns.get(index).get('params') : state.getIn(['settings', 'community']),
  }
};

const mapDispatchToProps = (dispatch, ownProps) => {
  return {
    onChange (key, checked) {
      if (ownProps.columnId) {
        dispatch(changeColumnParams(ownProps.columnId, key, checked));
      } else {
        dispatch(changeSetting(['community', ...key], checked));
      }
      ownProps.onChange(key, checked);
    },
  };
}

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
