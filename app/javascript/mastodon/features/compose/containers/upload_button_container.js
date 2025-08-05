import { connect } from 'react-redux';

import { uploadCompose } from '../../../actions/compose';
import UploadButton from '../components/upload_button';

const mapStateToProps = state => {
  const isPoll = state.compose.poll !== null;
  const isUploading = state.compose.is_uploading;
  const readyAttachmentsSize = state.compose.media_attachments.size ?? 0;
  const pendingAttachmentsSize = state.compose.pending_media_attachments.size ?? 0;
  const attachmentsSize = readyAttachmentsSize + pendingAttachmentsSize;
  const isOverLimit = attachmentsSize > state.getIn(['server', 'server', 'configuration', 'statuses', 'max_media_attachments'])-1;
  const hasVideoOrAudio = state.compose.media_attachments.some(m => ['video', 'audio'].includes(m.get('type')));

  return {
    disabled: isPoll || isUploading || isOverLimit || hasVideoOrAudio,
    resetFileKey: state.compose.resetFileKey,
  };
};

const mapDispatchToProps = dispatch => ({

  onSelectFile(files) {
    dispatch(uploadCompose(files));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(UploadButton);
