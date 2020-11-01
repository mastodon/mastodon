import { connect } from 'react-redux';
import Status from 'flavours/glitch/components/status';
import { List as ImmutableList } from 'immutable';
import { makeGetStatus, regexFromFilters, toServerSideType } from 'flavours/glitch/selectors';
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
import { muteStatus, unmuteStatus, deleteStatus } from 'flavours/glitch/actions/statuses';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { initBlockModal } from 'flavours/glitch/actions/blocks';
import { initReport } from 'flavours/glitch/actions/reports';
import { openModal } from 'flavours/glitch/actions/modal';
import { deployPictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { boostModal, favouriteModal, deleteModal } from 'flavours/glitch/util/initial_state';
import { filterEditLink } from 'flavours/glitch/util/backend_links';
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
  unfilterConfirm: { id: 'confirmations.unfilter.confirm', defaultMessage: 'Show' },
  author: { id: 'confirmations.unfilter.author', defaultMessage: 'Author' },
  matchingFilters: { id: 'confirmations.unfilter.filters', defaultMessage: 'Matching {count, plural, one {filter} other {filters}}' },
  editFilter: { id: 'confirmations.unfilter.edit_filter', defaultMessage: 'Edit filter' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

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
      containerId : props.containerId || props.id,  //  Should match reblogStatus's id for reblogs
      status      : status,
      account     : account || props.account,
      settings    : state.get('local_settings'),
      prepend     : prepend || props.prepend,
      usingPiP    : state.get('picture_in_picture').statusId === props.id,
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

  onModalReblog (status) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status));
    }
  },

  onReblog (status, e) {
    dispatch((_, getState) => {
      let state = getState();
      if (state.getIn(['local_settings', 'confirm_boost_missing_media_description']) && status.get('media_attachments').some(item => !item.get('description')) && !status.get('reblogged')) {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog, missingMediaDescription: true }));
      } else if (e.shiftKey || !boostModal) {
        this.onModalReblog(status);
      } else {
        dispatch(openModal('BOOST', { status, onReblog: this.onModalReblog }));
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

  onUnfilter (status, onConfirm) {
    dispatch((_, getState) => {
      let state = getState();
      const serverSideType = toServerSideType(contextType);
      const enabledFilters = state.get('filters', ImmutableList()).filter(filter => filter.get('context').includes(serverSideType) && (filter.get('expires_at') === null || Date.parse(filter.get('expires_at')) > (new Date()))).toArray();
      const searchIndex = status.get('search_index');
      const matchingFilters = enabledFilters.filter(filter => regexFromFilters([filter]).test(searchIndex));
      dispatch(openModal('CONFIRM', {
        message: [
          <FormattedMessage id='confirmations.unfilter' defaultMessage='Information about this filtered toot' />,
          <div className='filtered-status-info'>
            <Spoilers spoilerText={intl.formatMessage(messages.author)}>
              <AccountContainer id={status.getIn(['account', 'id'])} />
            </Spoilers>
            <Spoilers spoilerText={intl.formatMessage(messages.matchingFilters, {count: matchingFilters.size})}>
              <ul>
                {matchingFilters.map(filter => (
                  <li>
                    {filter.get('phrase')}
                    {!!filterEditLink && ' '}
                    {!!filterEditLink && (
                      <a
                        target='_blank'
                        className='filtered-status-edit-link'
                        title={intl.formatMessage(messages.editFilter)}
                        href={filterEditLink(filter.get('id'))}
                      >
                        <Icon id='pencil' />
                      </a>
                    )}
                  </li>
                ))}
              </ul>
            </Spoilers>
          </div>
        ],
        confirm: intl.formatMessage(messages.unfilterConfirm),
        onConfirm: onConfirm,
      }));
    });
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

  deployPictureInPicture (status, type, mediaProps) {
    dispatch((_, getState) => {
      if (getState().getIn(['local_settings', 'media', 'pop_in_player'])) {
        dispatch(deployPictureInPicture(status.get('id'), status.getIn(['account', 'id']), type, mediaProps));
      }
    });
  },

});

export default injectIntl(connect(makeMapStateToProps, mapDispatchToProps)(Status));
