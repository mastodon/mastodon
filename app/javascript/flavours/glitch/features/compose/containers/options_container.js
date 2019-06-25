import { connect } from 'react-redux';
import Options from '../components/options';
import {
  changeComposeAdvancedOption,
  changeComposeContentType,
  addPoll,
  removePoll,
} from 'flavours/glitch/actions/compose';
import { closeModal, openModal } from 'flavours/glitch/actions/modal';

function mapStateToProps (state) {
  const spoilersAlwaysOn = state.getIn(['local_settings', 'always_show_spoilers_field']);
  const poll = state.getIn(['compose', 'poll']);
  const media = state.getIn(['compose', 'media_attachments']);
  return {
    acceptContentTypes: state.getIn(['media_attachments', 'accept_content_types']).toArray().join(','),
    resetFileKey: state.getIn(['compose', 'resetFileKey']),
    hasPoll: !!poll,
    allowMedia: !poll && (media ? media.size < 4 && !media.some(item => ['video', 'audio'].includes(item.get('type'))) : true),
    hasMedia: media && !!media.size,
    allowPoll: !(media && !!media.size),
    showContentTypeChoice: state.getIn(['local_settings', 'show_content_type_choice']),
    contentType: state.getIn(['compose', 'content_type']),
  };
};

const mapDispatchToProps = (dispatch) => ({

  onChangeAdvancedOption(option, value) {
    dispatch(changeComposeAdvancedOption(option, value));
  },

  onChangeContentType(value) {
    dispatch(changeComposeContentType(value));
  },

  onTogglePoll() {
    dispatch((_, getState) => {
      if (getState().getIn(['compose', 'poll'])) {
        dispatch(removePoll());
      } else {
        dispatch(addPoll());
      }
    });
  },

  onDoodleOpen() {
    dispatch(openModal('DOODLE', { noEsc: true }));
  },

  onModalClose() {
    dispatch(closeModal());
  },

  onModalOpen(props) {
    dispatch(openModal('ACTIONS', props));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(Options);
