import { connect } from 'react-redux';
import ColumnSettings from '../components/column_settings';
import { changeSetting } from '../../../actions/settings';

const mapStateToProps = state => ({
  settings: state.getIn(['settings', 'community']),
});

const mapDispatchToProps = dispatch => ({

  onChange (key, checked) {
    dispatch(changeSetting(['community', ...key], checked));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
