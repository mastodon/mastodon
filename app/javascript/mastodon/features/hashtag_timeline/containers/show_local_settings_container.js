import { connect } from 'react-redux';
import ShowLocalSettings from '../components/show_local_settings';
import { changeSetting, saveSettings } from '../../../actions/settings';

const mapStateToProps = (state, { tag }) => ({
  settings: state.getIn(['settings', 'tag']),
});

const mapDispatchToProps = dispatch => ({

  onChange (tag, key, checked) {
    dispatch(changeSetting(['tag', `${tag}`, ...key], checked));
  },

  onSave () {
    dispatch(saveSettings());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ShowLocalSettings);
