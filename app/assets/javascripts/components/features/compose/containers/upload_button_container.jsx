import { connect } from 'react-redux';
import UploadButton from '../components/upload_button';
import { uploadCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size > 3 || state.getIn(['compose', 'media_attachments']).some(m => m.get('type') === 'video')),
  resetFileKey: state.getIn(['compose', 'resetFileKey'])
});

const mapDispatchToProps = dispatch => ({

  onSelectFile (files) {
    dispatch(uploadCompose(files));
  }

});

export default connect(mapStateToProps, mapDispatchToProps)(UploadButton);
