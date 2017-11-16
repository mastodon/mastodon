//  Package imports  //
import { connect } from 'react-redux';

//  Mastodon imports  //
import { closeModal } from '../../../mastodon/actions/modal';

//  Our imports  //
import { changeLocalSetting } from '../../../glitch/actions/local_settings';
import LocalSettings from '.';

const mapStateToProps = state => ({
  settings: state.get('local_settings'),
});

const mapDispatchToProps = dispatch => ({
  onChange (setting, value) {
    dispatch(changeLocalSetting(setting, value));
  },
  onClose () {
    dispatch(closeModal());
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(LocalSettings);
