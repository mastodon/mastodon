import { connect } from 'react-redux';
import Status from 'flavours/glitch/components/status';
import { List as ImmutableList } from 'immutable';
import { makeGetStatus, makeGetPictureInPicture } from 'flavours/glitch/selectors';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from 'flavours/glitch/actions/compose';
import {
  reblog,
  favourite,
  bookmark,
  unreblog,
  unfavourite,
  unbookmark,
  pin,
  unpin,
} from 'flavours/glitch/actions/interactions';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  hideStatus,
  revealStatus,
  editStatus,
  translateStatus,
  undoStatusTranslation,
} from 'flavours/glitch/actions/statuses';
import {
  initAddFilter,
} from 'flavours/glitch/actions/filters';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { initBlockModal } from 'flavours/glitch/actions/blocks';
import { initReport } from 'flavours/glitch/actions/reports';
import { initBoostModal } from 'flavours/glitch/actions/boosts';
import { openModal } from 'flavours/glitch/actions/modal';
import { deployPictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { boostModal, favouriteModal, deleteModal } from 'flavours/glitch/initial_state';
import { filterEditLink } from 'flavours/glitch/utils/backend_links';
import { showAlertForError } from '../actions/alerts';
import AccountContainer from 'flavours/glitch/containers/account_container';
import Spoilers from '../components/spoilers';
import Icon from 'flavours/glitch/components/icon';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? You will lose all replies, boosts and favourites to it.' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  editConfirm: { id: 'confirmations.edit.confirm', defaultMessage: 'Edit' },
  editMessage: { id: 'confirmations.edit.message', defaultMessage: 'Editing now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  unfilterConfirm: { id: 'confirmations.unfilter.confirm', defaultMessage: 'Show' },
  author: { id: 'confirmations.unfilter.author', defaultMessage: 'Author' },
  matchingFilters: { id: 'confirmations.unfilter.filters', defaultMessage: 'Matching {count, plural, one {filter} other {filters}}' },
  editFilter: { id: 'confirmations.unfilter.edit_filter', defaultMessage: 'Edit filter' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getPictureInPicture = makeGetPictureInPicture();

  const mapStateToProps = (state, props) => {

    let status = getStatus(state, props);
    let reblogStatus = status ? status.get('reblog', null) : null;
    let account = undefined;
    let prepend = undefined;

    if (props.featured && status) {
      account = status.get('account');
      prepend = 'featured';
    } else if (reblogStatus !== null && typeof reblogStatus === 'object') {
      account = status.get('account');
      status = reblogStatus;
      prepend = 'reblogged_by';
    }

    return {
      containerId: props.containerId || props.id,  //  Should match reblogStatus's id for reblogs
      status: status,
      account: account || props.account,
      settings: state.get('local_settings'),
      prepend: prepend || props.prepend,
      pictureInPicture: getPictureInPicture(state, props),
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { intl, contextType }) => ({

  onReply (status, router) {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['local_settings', 'confirm_before_clearing_draft']) && state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.replyMessage),
          confirm: intl.formatMessage(messages.replyConfirm),
          onDoNotAsk: () => dispatch(changeLocalSetting(['confirm_before_clearing_draft'], false)),
          onConfirm: () => dispatch(replyCompose(status, router)),
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
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['local_settings', 'confirm_boost_missing_media_description']) && status.get('media_attachments').some(item => !item.get('description')) && !status.get('reblogged')) {
        dispatch(initBoostModal({ status, onReblog: this.onModalReblog, missingMediaDescription: true }));
      } else if (e.shiftKey || !boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(initBoostModal({ status, onReblog: this.onModalReblog }));
      }
    });
  },

  onBookmark (status) {
    if (status.get('bookmarked')) {
      dispatch(unbookmark(status));
    } else {
      dispatch(bookmark(status));
    }
  },

  onModalFavourite (status) {
    dispatch(favourite(status));
  },

  onFavourite (status, e) {
    if (status.get('favourited')) {
      dispatch(unfavourite(status));
    } else {
      if (e.shiftKey || !favouriteModal) {
        this.onModalFavourite(status);
      } else {
        dispatch(openModal('FAVOURITE', { status, onFavourite: this.onModalFavourite }));
      }
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

  onEdit (status, history) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.editMessage),
          confirm: intl.formatMessage(messages.editConfirm),
          onConfirm: () => dispatch(editStatus(status.get('id'), history)),
        }));
      } else {
        dispatch(editStatus(status.get('id'), history));
      }
    });
  },

  onTranslate (status) {
    if (status.get('translation')) {
      dispatch(undoStatusTranslation(status.get('id')));
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

  onOpenMedia (statusId, media, index) {
    dispatch(openModal('MEDIA', { statusId, media, index }));
  },

  onOpenVideo (statusId, media, options) {
    dispatch(openModal('VIDEO', { statusId, media, options }));
  },

  onBlock (status) {
    const account = status.get('account');
    dispatch(initBlockModal(account));
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

  deployPictureInPicture (status, type, mediaProps) {
    dispatch((_, getState) => {
      if (getState().getIn(['local_settings', 'media', 'pop_in_player'])) {
        dispatch(deployPictureInPicture(status.get('id'), status.getIn(['account', 'id']), type, mediaProps));
      }
    });
  },

  onInteractionModal (type, status) {
    dispatch(openModal('INTERACTION', {
      type,
      accountId: status.getIn(['account', 'id']),
      url: status.get('url'),
    }));
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Status));
