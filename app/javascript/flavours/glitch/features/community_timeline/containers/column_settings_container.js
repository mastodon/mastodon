import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting } from 'flavours/glitch/actions/settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'community']),
});

const mapDispatchToProps = dispatch => ({

  onChange (path, checked) {
    dispatch(changeSetting(['community', ...path], checked));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
