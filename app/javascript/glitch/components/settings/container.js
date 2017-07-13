//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { closeModal } from '../../../mastodon/actions/modal';

//  Our imports  //
import { changeLocalSetting } from '../../actions/local_settings';
import Settings from '../../components/settings';

const mapStateToProps = state => ({
  settings: state.get('local_settings'),
});

const mapDispatchToProps = dispatch => ({
  toggleSetting (setting, e) {
    dispatch(changeLocalSetting(setting, e.target.checked));
  },
  changeSetting (setting, e) {
    dispatch(changeLocalSetting(setting, e.target.value));
  },
  onClose () {
    dispatch(closeModal());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Settings);
