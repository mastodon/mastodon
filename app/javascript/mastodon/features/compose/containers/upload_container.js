import { connect } from 'react-redux';
import Upload from '../components/upload';
import { undoUploadCompose } from '../../../actions/compose';
import { openModal } from '../../../actions/modal';
import { submitCompose } from '../../../actions/compose';

const mapStateToProps = (state, { id }) => ({
  media: state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id),
});

const mapDispatchToProps = dispatch => ({

  onUndo: id => {
    dispatch(undoUploadCompose(id));
  },

  onOpenFocalPoint: id => {
    dispatch(openModal('FOCAL_POINT', { id }));
  },

  onSubmit (router) {
    dispatch(submitCompose(router));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Upload);
