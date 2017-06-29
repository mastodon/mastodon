import { connect } from 'react-redux';
import { changeLocalSetting } from '../../../actions/local_settings';
import { closeModal } from '../../../actions/modal';
import SettingsModal from '../components/settings_modal';

const mapStateToProps = state => ({
  settings: state.get('local_settings'),
});

const mapDispatchToProps = dispatch => ({
  toggleSetting (setting, e) {
    dispatch(changeLocalSetting(setting, e.target.checked));
  },
  onClose () {
    dispatch(closeModal());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(SettingsModal);
