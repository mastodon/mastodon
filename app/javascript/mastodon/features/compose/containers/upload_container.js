import { connect } from 'react-redux';
import Upload from '../components/upload';
import { undoUploadCompose, changeUploadCompose } from '../../../actions/compose';

const mapStateToProps = (state, { id }) => ({
  media: state.getIn(['compose', 'media_attachments']).find(item => item.get('id') === id),
});

const mapDispatchToProps = dispatch => ({

  onUndo: id => {
    dispatch(undoUploadCompose(id));
  },

  onDescriptionChange: (id, description) => {
    dispatch(changeUploadCompose(id, description));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(Upload);
