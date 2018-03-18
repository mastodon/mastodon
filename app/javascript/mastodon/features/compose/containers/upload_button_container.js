import { connect } from 'react-redux';
import UploadButton from '../components/upload_button';
import { uploadCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  disabled: state.compose.get('is_uploading') || (state.compose.get('media_attachments').size > 3 || state.compose.get('media_attachments').some(m => m.get('type') === 'video')),
  resetFileKey: state.compose.get('resetFileKey'),
});

const mapDispatchToProps = dispatch => ({

  onSelectFile (files) {
    dispatch(uploadCompose(files));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(UploadButton);
