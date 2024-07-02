import { injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import { confirmDeleteStatus, confirmReply } from 'mastodon/utils/confirmations';

import { showAlertForError } from '../../../actions/alerts';
import { initBlockModal } from '../../../actions/blocks';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from '../../../actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite,
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
  hideStatus,
  revealStatus,
} from '../../../actions/statuses';
import { boostModal, deleteModal } from '../../../initial_state';
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

const mapDispatchToProps = (dispatch, { intl }) => ({

  onReply (status, router) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        confirmReply(dispatch, intl, router, status);
      } else {
        dispatch(replyCompose(status, router));
      }
    });
  },

  onModalReblog (status, privacy) {
    dispatch(reblog({ statusId: status.get('id'), visibility: privacy }));
  },

  onReblog (status, e) {
    if (status.get('reblogged')) {
      dispatch(unreblog({ statusId: status.get('id') }));
    } else {
      if (e.shiftKey || !boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal({ modalType: 'BOOST', modalProps: { status, onReblog: this.onModalReblog } }));
      }
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
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

  onDelete (status, history, withRedraft = false) {
    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), history, withRedraft));
    } else {
      confirmDeleteStatus(dispatch, intl, history, status.get('id'), withRedraft);
    }
  },

  onDirect (account, router) {
    dispatch(directCompose(account, router));
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
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
    if (status.get('hidden')) {
      dispatch(revealStatus(status.get('id')));
    } else {
      dispatch(hideStatus(status.get('id')));
    }
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(DetailedStatus));
