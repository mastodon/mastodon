import { connect } from 'react-redux';
import UploadButton from '../components/upload_button';
import { uploadCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  disabled: state.getIn(['compose', 'is_uploading']) || (state.getIn(['compose', 'media_attachments']).size + state.getIn(['compose', 'pending_media_attachments']) > 8 || state.getIn(['compose', 'media_attachments']).some(m => ['video', 'audio'].includes(m.get('type')))),
  unavailable: state.getIn(['compose', 'poll']) !== null,
  resetFileKey: state.getIn(['compose', 'resetFileKey']),
});

const mapDispatchToProps = dispatch => ({

  onSelectFile (files) {
    dispatch(uploadCompose(files));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(UploadButton);
