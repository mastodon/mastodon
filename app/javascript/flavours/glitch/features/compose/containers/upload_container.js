import { connect } from 'react-redux';

import { undoUploadCompose, initMediaEditModal, submitCompose } from 'flavours/glitch/actions/compose';

import Upload from '../components/upload';

const mapStateToProps = (state, { id }) => ({
  media: state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id),
});

const mapDispatchToProps = dispatch => ({

  onUndo: id => {
    dispatch(undoUploadCompose(id));
  },

  onOpenFocalPoint: id => {
    dispatch(initMediaEditModal(id));
  },

  onSubmit (router) {
    dispatch(submitCompose(router));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Upload);
