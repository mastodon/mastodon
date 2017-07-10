import { connect } from 'react-redux';
import UploadForm from '../components/upload_form';
import { undoUploadCompose } from '../../../actions/compose';

const mapStateToProps = state => ({
  media: state.getIn(['compose', 'media_attachments']),
});

const mapDispatchToProps = dispatch => ({

  onRemoveFile (media_id) {
    dispatch(undoUploadCompose(media_id));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(UploadForm);
