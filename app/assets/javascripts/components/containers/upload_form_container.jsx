import { connect }                          from 'react-redux';
import UploadForm                           from '../components/upload_form';
import { uploadCompose, undoUploadCompose } from '../actions/compose';

const mapStateToProps = function (state, props) {
  return {
    media: state.getIn(['compose', 'media_attachments']),
    progress: state.getIn(['compose', 'progress']),
    is_uploading: state.getIn(['compose', 'is_uploading'])
  };
};

const mapDispatchToProps = function (dispatch) {
  return {
    onSelectFile: function (files) {
      dispatch(uploadCompose(files));
    },

    onRemoveFile: function (media_id) {
      dispatch(undoUploadCompose(media_id));
    }
  }
};

export default connect(mapStateToProps, mapDispatchToProps)(UploadForm);
