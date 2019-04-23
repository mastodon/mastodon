import { connect } from 'react-redux';
import HashtagTemp from '../components/hashtag_temp';
import {
  updateTextTagTemplate,
  addTagTemplate,
  delTagTemplate,
  enableTagTemplate,
  disableTagTemplate
} from '../../../actions/compose';

const mapStateToProps = state => ({
  tagTemplate : state.getIn(['compose', 'tagTemplate']),
});

const mapDispatchToProps = dispatch => ({
  onChangeTagTemplate (tag, index) {
    dispatch(updateTextTagTemplate(tag, index));
  },

  onAddTagTemplate (index) {
    dispatch(addTagTemplate(index));
  },

  onDeleteTagTemplate (index) {
    dispatch(delTagTemplate(index));
  },

  onEnableTagTemplate (index) {
    dispatch(enableTagTemplate(index));
  },

  onDisableTagTemplate (index) {
    dispatch(disableTagTemplate(index));
  }
});

export default connect(mapStateToProps, mapDispatchToProps)(HashtagTemp);
