import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { showAlertForError } from '../../../actions/alerts';
import { initBlockModal } from '../../../actions/blocks';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from '../../../actions/compose';
import {
  toggleReblog,
  toggleFavourite,
  pin,
  unpin,
} from '../../../actions/interactions';
import { openModal } from '../../../actions/modal';
import { initMuteModal } from '../../../actions/mutes';
import { initReport } from '../../../actions/reports';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  toggleStatusSpoilers,
} from '../../../actions/statuses';
import { deleteModal } from '../../../initial_state';
import { makeGetStatus, makeGetPictureInPicture } from '../../../selectors';
import DetailedStatus from '../components/detailed_status';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getPictureInPicture = makeGetPictureInPicture();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, props),
    domain: state.getIn(['meta', 'domain']),
    pictureInPicture: getPictureInPicture(state, props),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({

  onReply (status) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }));
      } else {
        dispatch(replyCompose(status));
      }
    });
  },

  onReblog (status, e) {
    dispatch(toggleReblog(status.get('id'), e.shiftKey));
  },

  onFavourite (status) {
    dispatch(toggleFavourite(status.get('id')));
  },

  onPin (status) {
    if (status.get('pinned')) {
      dispatch(unpin(status));
    } else {
      dispatch(pin(status));
    }
  },

  onEmbed (status) {
    dispatch(openModal({
      modalType: 'EMBED',
      modalProps: {
        id: status.get('id'),
        onError: error => dispatch(showAlertForError(error)),
      },
    }));
  },

  onDelete (status, withRedraft = false) {
    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), withRedraft));
    } else {
      dispatch(openModal({ modalType: 'CONFIRM_DELETE_STATUS', modalProps: { statusId: status.get('id'), withRedraft } }));
    }
  },

  onDirect (account) {
    dispatch(directCompose(account));
  },

  onMention (account) {
    dispatch(mentionCompose(account));
  },

  onOpenMedia (media, index, lang) {
    dispatch(openModal({
      modalType: 'MEDIA',
      modalProps: { media, index, lang },
    }));
  },

  onOpenVideo (media, lang, options) {
    dispatch(openModal({
      modalType: 'VIDEO',
      modalProps: { media, lang, options },
    }));
  },

  onBlock (status) {
    const account = status.get('account');
    dispatch(initBlockModal(account));
  },

  onReport (status) {
    dispatch(initReport(status.get('account'), status));
  },

  onMute (account) {
    dispatch(initMuteModal(account));
  },

  onMuteConversation (status) {
    if (status.get('muted')) {
      dispatch(unmuteStatus(status.get('id')));
    } else {
      dispatch(muteStatus(status.get('id')));
    }
  },

  onToggleHidden (status) {
    dispatch(toggleStatusSpoilers(status.get('id')));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(DetailedStatus));
