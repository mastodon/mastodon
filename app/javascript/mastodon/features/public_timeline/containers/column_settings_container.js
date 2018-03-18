import { connect } from 'react-redux';
import ColumnSettings from '../../community_timeline/components/column_settings';
import { changeSetting } from '../../../actions/settings';

const mapStateToProps = state => ({
  settings: state.settings.get('public'),
});

const mapDispatchToProps = dispatch => ({

  onChange (key, checked) {
    dispatch(changeSetting(['public', ...key], checked));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ColumnSettings);
