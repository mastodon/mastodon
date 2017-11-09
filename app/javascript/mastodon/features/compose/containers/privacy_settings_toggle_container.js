import { connect } from 'react-redux';
import PrivacySettingsToggle from '../components/privacy_settings_toggle';
import { changeComposeFederate } from '../../../actions/compose';

const mapStateToProps = state => ({
  settings: state.getIn(['compose']),
});

const mapDispatchToProps = dispatch => ({

  onChange () {
    dispatch(changeComposeFederate());
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(PrivacySettingsToggle);
