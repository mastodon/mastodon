import { connect } from 'react-redux';
import SensitiveToggle from '../components/sensitive_toggle';
import { changeComposeSensitivity } from '../../../actions/compose';

const mapStateToProps = state => ({
  hasMedia: state.getIn(['compose', 'media_attachments']).size > 0,
  isSensitive: state.getIn(['compose', 'sensitive'])
});

const mapDispatchToProps = dispatch => ({

  onChange (e) {
    dispatch(changeComposeSensitivity(e.target.checked));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(SensitiveToggle);
