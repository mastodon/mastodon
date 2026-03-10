import { connect } from 'react-redux';

import { initBlockModal } from 'flavours/glitch/actions/blocks';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from 'flavours/glitch/actions/compose';
import { quoteComposeById } from 'flavours/glitch/actions/compose_typed';
import {
  initAddFilter,
} from 'flavours/glitch/actions/filters';
import {
  toggleReblog,
  toggleFavourite,
  bookmark,
  unbookmark,
  pin,
  unpin,
} from 'flavours/glitch/actions/interactions';
import { openModal } from 'flavours/glitch/actions/modal';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { deployPictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import { initReport } from 'flavours/glitch/actions/reports';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  toggleStatusSpoilers,
  toggleStatusCollapse,
  editStatus,
  translateStatus,
  undoStatusTranslation,
} from 'flavours/glitch/actions/statuses';
import Status from 'flavours/glitch/components/status';
import { deleteModal } from 'flavours/glitch/initial_state';
import { makeGetStatus, makeGetPictureInPicture } from 'flavours/glitch/selectors';

import { setStatusQuotePolicy } from '../actions/statuses_typed';

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getPictureInPicture = makeGetPictureInPicture();

  const mapStateToProps = (state, props) => {

    let status = getStatus(state, props);
    let reblogStatus = status ? status.get('reblog', null) : null;
    let account = undefined;
    let prepend = undefined;

    if (reblogStatus !== null && typeof reblogStatus === 'object') {
      account = status.get('account');
      status = reblogStatus;
      prepend = 'reblogged_by';
    }

    return {
      containerId: props.containerId || props.id,  //  Should match reblogStatus's id for reblogs
      status: status,
      nextInReplyToId: props.nextId ? state.getIn(['statuses', props.nextId, 'in_reply_to_id']) : null,
      account: account || props.account,
      settings: state.get('local_settings'),
      prepend: prepend || props.prepend,
      pictureInPicture: getPictureInPicture(state, props),
    };
  };

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch, { contextType }) => ({

  onReply (status) {
    dispatch((_, getState) => {
      let state = getState();

      if (state.getIn(['local_settings', 'confirm_before_clearing_draft']) && state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }));
      } else {
        dispatch(replyCompose(status));
      }
    });
  },

  onQuote (status) {
    dispatch(quoteComposeById(status.get('id')));
  },

  onReblog (status, e) {
    dispatch(toggleReblog(status.get('id'), e.shiftKey));
  },

  onBookmark (status) {
    if (status.get('bookmarked')) {
      dispatch(unbookmark(status));
    } else {
      dispatch(bookmark(status));
    }
  },

  onFavourite (status, e) {
    dispatch(toggleFavourite(status.get('id'), e.shiftKey));
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
      modalProps: { id: status.get('id') },
    }));
  },

  onDelete (status, withRedraft = false) {
    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), withRedraft));
    } else {
      dispatch(openModal({
        modalType: 'CONFIRM_DELETE_STATUS',
        modalProps: {
          statusId: status.get('id'),
          withRedraft
        }
      }));
    }
  },

  onRevokeQuote (status) {
    dispatch(openModal({ modalType: 'CONFIRM_REVOKE_QUOTE', modalProps: { statusId: status.get('id'), quotedStatusId: status.getIn(['quote', 'quoted_status']) }}));
  },

  onQuotePolicyChange(status) {
    const statusId = status.get('id');
    const handleChange = (_, quotePolicy) => {
      dispatch(
        setStatusQuotePolicy({ policy: quotePolicy, statusId }),
      );
    }
    dispatch(openModal({ modalType: 'COMPOSE_PRIVACY', modalProps: { statusId, onChange: handleChange } }));
  },

  onEdit (status) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['compose', 'text']).trim().length !== 0) {
        dispatch(openModal({ modalType: 'CONFIRM_EDIT_STATUS', modalProps: { statusId: status.get('id') } }));
      } else {
        dispatch(editStatus(status.get('id')));
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

  onDirect (account) {
    dispatch(directCompose(account));
  },

  onMention (account) {
    dispatch(mentionCompose(account));
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
    dispatch(toggleStatusSpoilers(status.get('id')));
  },

  onToggleCollapsed (status, isCollapsed) {
    dispatch(toggleStatusCollapse(status.get('id'), isCollapsed));
  },


  deployPictureInPicture (status, type, mediaProps) {
    dispatch((_, getState) => {
      if (getState().getIn(['local_settings', 'media', 'pop_in_player'])) {
        dispatch(deployPictureInPicture({statusId: status.get('id'), accountId: status.getIn(['account', 'id']), playerType: type, props: mediaProps}));
      }
    });
  },

  onInteractionModal (status, intent) {
    dispatch(openModal({
      modalType: 'INTERACTION',
      modalProps: {
        intent,
        accountId: status.getIn(['account', 'id']),
        url: status.get('uri'),
      },
    }));
  },

});

export default connect(makeMapStateToProps, mapDispatchToProps)(Status);
