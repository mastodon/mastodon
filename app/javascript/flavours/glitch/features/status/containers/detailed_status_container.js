import { connect } from 'react-redux';
import DetailedStatus from '../components/detailed_status';
import { makeGetStatus } from 'flavours/glitch/selectors';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from 'flavours/glitch/actions/compose';
import {
  reblog,
  favourite,
  unreblog,
  unfavourite,
  pin,
  unpin,
} from 'flavours/glitch/actions/interactions';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  hideStatus,
  revealStatus,
} from 'flavours/glitch/actions/statuses';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { initBlockModal } from 'flavours/glitch/actions/blocks';
import { initReport } from 'flavours/glitch/actions/reports';
import { openModal } from 'flavours/glitch/actions/modal';
import { defineMessages, injectIntl } from 'react-intl';
import { boostModal, deleteModal } from 'flavours/glitch/util/initial_state';
import { showAlertForError } from 'flavours/glitch/actions/alerts';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? Favourites and boosts will be lost, and replies to the original post will be orphaned.' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, props),
    domain: state.getIn(['meta', 'domain']),
    settings: state.get('local_settings'),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl }) => ({

  onReply (status, router) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.replyMessage),
          confirm: intl.formatMessage(messages.replyConfirm),
          onConfirm: () => dispatch(replyCompose(status, router)),
        }));
      } else {
        dispatch(replyCompose(status, router));
      }
    });
  },

  onModalReblog (status) {
    dispatch(reblog(status));
  },

  onReblog (status, e) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      if (e.shiftKey || !boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog }));
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
    dispatch(openModal('EMBED', {
      url: status.get('url'),
      onError: error => dispatch(showAlertForError(error)),
    }));
  },

  onDelete (status, history, withRedraft = false) {
    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), history, withRedraft));
    } else {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(withRedraft ? messages.redraftMessage : messages.deleteMessage),
        confirm: intl.formatMessage(withRedraft ? messages.redraftConfirm : messages.deleteConfirm),
        onConfirm: () => dispatch(deleteStatus(status.get('id'), history, withRedraft)),
      }));
    }
  },

  onDirect (account, router) {
    dispatch(directCompose(account, router));
  },

  onMention (account, router) {
    dispatch(mentionCompose(account, router));
  },

  onOpenMedia (media, index) {
    dispatch(openModal('MEDIA', { media, index }));
  },

  onOpenVideo (media, options) {
    dispatch(openModal('VIDEO', { media, options }));
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

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(DetailedStatus));
