import { defineMessages, injectIntl } from 'react-intl';

import { connect } from 'react-redux';

import {
  unmuteAccount,
  unblockAccount,
} from '../actions/accounts';
import { showAlertForError } from '../actions/alerts';
import { initBlockModal } from '../actions/blocks';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from '../actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from '../actions/domain_blocks';
import {
  initAddFilter,
} from '../actions/filters';
import {
  reblog,
  favourite,
  bookmark,
  unreblog,
  unfavourite,
  unbookmark,
  pin,
  unpin,
} from '../actions/interactions';
import { openModal } from '../actions/modal';
import { initMuteModal } from '../actions/mutes';
import { deployPictureInPicture } from '../actions/picture_in_picture';
import { initReport } from '../actions/reports';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  hideStatus,
  revealStatus,
  toggleStatusCollapse,
  editStatus,
  translateStatus,
  undoStatusTranslation,
} from '../actions/statuses';
import Status from '../components/status';
import { boostModal, deleteModal } from '../initial_state';
import { makeGetStatus, makeGetPictureInPicture } from '../selectors';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? Favorites and boosts will be lost, and replies to the original post will be orphaned.' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  editConfirm: { id: 'confirmations.edit.confirm', defaultMessage: 'Edit' },
  editMessage: { id: 'confirmations.edit.message', defaultMessage: 'Editing now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  blockDomainConfirm: { id: 'confirmations.domain_block.confirm', defaultMessage: 'Block entire domain' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getPictureInPicture = makeGetPictureInPicture();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, props),
    nextInReplyToId: props.nextId ? state.getIn(['statuses', props.nextId, 'in_reply_to_id']) : null,
    pictureInPicture: getPictureInPicture(state, props),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl, contextType }) => ({

  onReply (status, router) {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: intl.formatMessage(messages.replyMessage),
            confirm: intl.formatMessage(messages.replyConfirm),
            onConfirm: () => dispatch(replyCompose(status, router)) },
        }));
      } else {
        dispatch(replyCompose(status, router));
      }
    });
  },

  onModalReblog (status, privacy) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status, privacy));
    }
  },

  onReblog (status, e) {
    if ((e && e.shiftKey) || !boostModal) {
      this.onModalReblog(status);
    } else {
      dispatch(openModal({ modalType: 'BOOST', modalProps: { status, onReblog: this.onModalReblog } }));
    }
  },

  onFavourite (status) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      dispatch(favourite(status));
    }
  },

  onBookmark (status) {
    if (status.get('bookmarked')) {
      dispatch(unbookmark(status));
    } else {
      dispatch(bookmark(status));
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
      dispatch(openModal({
        modalType: 'CONFIRM',
        modalProps: {
          message: intl.formatMessage(withRedraft ? messages.redraftMessage : messages.deleteMessage),
          confirm: intl.formatMessage(withRedraft ? messages.redraftConfirm : messages.deleteConfirm),
          onConfirm: () => dispatch(deleteStatus(status.get('id'), history, withRedraft)),
        },
      }));
    }
  },

  onEdit (status, history) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({
          modalType: 'CONFIRM',
          modalProps: {
            message: intl.formatMessage(messages.editMessage),
            confirm: intl.formatMessage(messages.editConfirm),
            onConfirm: () => dispatch(editStatus(status.get('id'), history)),
          },
        }));
      } else {
        dispatch(editStatus(status.get('id'), history));
      }
    });
  },

  onTranslate (status) {
    if (status.get('translation')) {
      dispatch(undoStatusTranslation(status.get('id'), status.get('poll')));
    } else {
      dispatch(translateStatus(status.get('id')));
    }
  },

  onDirect (account, router) {
    dispatch(directCompose(account, router));
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onOpenMedia (statusId, media, index, lang) {
    dispatch(openModal({
      modalType: 'MEDIA',
      modalProps: { statusId, media, index, lang },
    }));
  },

  onOpenVideo (statusId, media, lang, options) {
    dispatch(openModal({
      modalType: 'VIDEO',
      modalProps: { statusId, media, lang, options },
    }));
  },

  onBlock (status) {
    const account = status.get('account');
    dispatch(initBlockModal(account));
  },

  onUnblock (account) {
    dispatch(unblockAccount(account.get('id')));
  },

  onReport (status) {
    dispatch(initReport(status.get('account'), status));
  },

  onAddFilter (status) {
    dispatch(initAddFilter(status, { contextType }));
  },

  onMute (account) {
    dispatch(initMuteModal(account));
  },

  onUnmute (account) {
    dispatch(unmuteAccount(account.get('id')));
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

  onToggleCollapsed (status, isCollapsed) {
    dispatch(toggleStatusCollapse(status.get('id'), isCollapsed));
  },

  onBlockDomain (account) {
    dispatch(initDomainBlockModal(account));
  },

  onUnblockDomain (domain) {
    dispatch(unblockDomain(domain));
  },

  deployPictureInPicture (status, type, mediaProps) {
    dispatch(deployPictureInPicture({statusId: status.get('id'), accountId: status.getIn(['account', 'id']), playerType: type, props: mediaProps}));
  },

  onInteractionModal (type, status) {
    dispatch(openModal({
      modalType: 'INTERACTION',
      modalProps: {
        type,
        accountId: status.getIn(['account', 'id']),
        url: status.get('uri'),
      },
    }));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Status));
