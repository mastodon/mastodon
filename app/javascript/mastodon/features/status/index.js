import Immutable from 'immutable';
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { createSelector } from 'reselect';
import { fetchStatus } from '../../actions/statuses';
import MissingIndicator from '../../components/missing_indicator';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import DetailedStatus from './components/detailed_status';
import ActionBar from './components/action_bar';
import Column from '../ui/components/column';
import {
  favourite,
  unfavourite,
  bookmark,
  unbookmark,
  reblog,
  unreblog,
  pin,
  unpin,
} from '../../actions/interactions';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from '../../actions/compose';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  editStatus,
  hideStatus,
  revealStatus,
  translateStatus,
  undoStatusTranslation,
} from '../../actions/statuses';
import {
  unblockAccount,
  unmuteAccount,
} from '../../actions/accounts';
import {
  blockDomain,
  unblockDomain,
} from '../../actions/domain_blocks';
import { initMuteModal } from '../../actions/mutes';
import { initBlockModal } from '../../actions/blocks';
import { initBoostModal } from '../../actions/boosts';
import { initReport } from '../../actions/reports';
import { makeGetStatus, makeGetPictureInPicture } from '../../selectors';
import ScrollContainer from 'mastodon/containers/scroll_container';
import ColumnBackButton from '../../components/column_back_button';
import ColumnHeader from '../../components/column_header';
import StatusContainer from '../../containers/status_container';
import { openModal } from '../../actions/modal';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { HotKeys } from 'react-hotkeys';
import { boostModal, deleteModal } from '../../initial_state';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from '../ui/util/fullscreen';
import { textForScreenReader, defaultMediaVisibility } from '../../components/status';
import Icon from 'mastodon/components/icon';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? Favourites and boosts will be lost, and replies to the original post will be orphaned.' },
  revealAll: { id: 'status.show_more_all', defaultMessage: 'Show more for all' },
  hideAll: { id: 'status.show_less_all', defaultMessage: 'Show less for all' },
  detailedStatus: { id: 'status.detailed_status', defaultMessage: 'Detailed conversation view' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  blockDomainConfirm: { id: 'confirmations.domain_block.confirm', defaultMessage: 'Hide entire domain' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();
  const getPictureInPicture = makeGetPictureInPicture();

  const getAncestorsIds = createSelector([
    (_, { id }) => id,
    state => state.getIn(['contexts', 'inReplyTos']),
  ], (statusId, inReplyTos) => {
    let ancestorsIds = Immutable.List();
    ancestorsIds = ancestorsIds.withMutations(mutable => {
      let id = statusId;

      while (id && !mutable.includes(id)) {
        mutable.unshift(id);
        id = inReplyTos.get(id);
      }
    });

    return ancestorsIds;
  });

  const getDescendantsIds = createSelector([
    (_, { id }) => id,
    state => state.getIn(['contexts', 'replies']),
    state => state.get('statuses'),
  ], (statusId, contextReplies, statuses) => {
    let descendantsIds = [];
    const ids = [statusId];

    while (ids.length > 0) {
      let id        = ids.pop();
      const replies = contextReplies.get(id);

      if (statusId !== id) {
        descendantsIds.push(id);
      }

      if (replies) {
        replies.reverse().forEach(reply => {
          if (!ids.includes(reply) && !descendantsIds.includes(reply) && statusId !== reply) ids.push(reply);
        });
      }
    }

    let insertAt = descendantsIds.findIndex((id) => statuses.get(id).get('in_reply_to_account_id') !== statuses.get(id).get('account'));
    if (insertAt !== -1) {
      descendantsIds.forEach((id, idx) => {
        if (idx > insertAt && statuses.get(id).get('in_reply_to_account_id') === statuses.get(id).get('account')) {
          descendantsIds.splice(idx, 1);
          descendantsIds.splice(insertAt, 0, id);
          insertAt += 1;
        }
      });
    }

    return Immutable.List(descendantsIds);
  });

  const mapStateToProps = (state, props) => {
    const status = getStatus(state, { id: props.params.statusId });

    let ancestorsIds   = Immutable.List();
    let descendantsIds = Immutable.List();

    if (status) {
      ancestorsIds   = getAncestorsIds(state, { id: status.get('in_reply_to_id') });
      descendantsIds = getDescendantsIds(state, { id: status.get('id') });
    }

    return {
      isLoading: state.getIn(['statuses', props.params.statusId, 'isLoading']),
      status,
      ancestorsIds,
      descendantsIds,
      askReplyConfirmation: state.getIn(['compose', 'text']).trim().length !== 0,
      domain: state.getIn(['meta', 'domain']),
      pictureInPicture: getPictureInPicture(state, { id: props.params.statusId }),
    };
  };

  return mapStateToProps;
};

const truncate = (str, num) => {
  if (str.length > num) {
    return str.slice(0, num) + '…';
  } else {
    return str;
  }
};

const titleFromStatus = status => {
  const displayName = status.getIn(['account', 'display_name']);
  const username = status.getIn(['account', 'username']);
  const prefix = displayName.trim().length === 0 ? username : displayName;
  const text = status.get('search_index');

  return `${prefix}: "${truncate(text, 30)}"`;
};

export default @injectIntl
@connect(makeMapStateToProps)
class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    isLoading: PropTypes.bool,
    ancestorsIds: ImmutablePropTypes.list,
    descendantsIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    askReplyConfirmation: PropTypes.bool,
    multiColumn: PropTypes.bool,
    domain: PropTypes.string.isRequired,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
  };

  state = {
    fullscreen: false,
    showMedia: defaultMediaVisibility(this.props.status),
    loadedStatusId: undefined,
  };

  componentWillMount () {
    this.props.dispatch(fetchStatus(this.props.params.statusId));
  }

  componentDidMount () {
    attachFullscreenListener(this.onFullScreenChange);
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this._scrolledIntoView = false;
      this.props.dispatch(fetchStatus(nextProps.params.statusId));
    }

    if (nextProps.params.statusId && nextProps.ancestorsIds.size > this.props.ancestorsIds.size) {
      this._scrolledIntoView = false;
    }

    if (nextProps.status && nextProps.status.get('id') !== this.state.loadedStatusId) {
      this.setState({ showMedia: defaultMediaVisibility(nextProps.status), loadedStatusId: nextProps.status.get('id') });
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  };

  handleFavouriteClick = (status) => {
    const { dispatch } = this.props;
    const { signedIn } = this.context.identity;

    if (signedIn) {
      if (status.get('favourited')) {
        dispatch(unfavourite(status));
      } else {
        dispatch(favourite(status));
      }
    } else {
      dispatch(openModal('INTERACTION', {
        type: 'favourite',
        accountId: status.getIn(['account', 'id']),
        url: status.get('url'),
      }));
    }
  };

  handlePin = (status) => {
    if (status.get('pinned')) {
      this.props.dispatch(unpin(status));
    } else {
      this.props.dispatch(pin(status));
    }
  };

  handleReplyClick = (status) => {
    const { askReplyConfirmation, dispatch, intl } = this.props;
    const { signedIn } = this.context.identity;

    if (signedIn) {
      if (askReplyConfirmation) {
        dispatch(openModal('CONFIRM', {
          message: intl.formatMessage(messages.replyMessage),
          confirm: intl.formatMessage(messages.replyConfirm),
          onConfirm: () => dispatch(replyCompose(status, this.context.router.history)),
        }));
      } else {
        dispatch(replyCompose(status, this.context.router.history));
      }
    } else {
      dispatch(openModal('INTERACTION', {
        type: 'reply',
        accountId: status.getIn(['account', 'id']),
        url: status.get('url'),
      }));
    }
  };

  handleModalReblog = (status, privacy) => {
    this.props.dispatch(reblog(status, privacy));
  };

  handleReblogClick = (status, e) => {
    const { dispatch } = this.props;
    const { signedIn } = this.context.identity;

    if (signedIn) {
      if (status.get('reblogged')) {
        dispatch(unreblog(status));
      } else {
        if ((e && e.shiftKey) || !boostModal) {
          this.handleModalReblog(status);
        } else {
          dispatch(initBoostModal({ status, onReblog: this.handleModalReblog }));
        }
      }
    } else {
      dispatch(openModal('INTERACTION', {
        type: 'reblog',
        accountId: status.getIn(['account', 'id']),
        url: status.get('url'),
      }));
    }
  };

  handleBookmarkClick = (status) => {
    if (status.get('bookmarked')) {
      this.props.dispatch(unbookmark(status));
    } else {
      this.props.dispatch(bookmark(status));
    }
  };

  handleDeleteClick = (status, history, withRedraft = false) => {
    const { dispatch, intl } = this.props;

    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), history, withRedraft));
    } else {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(withRedraft ? messages.redraftMessage : messages.deleteMessage),
        confirm: intl.formatMessage(withRedraft ? messages.redraftConfirm : messages.deleteConfirm),
        onConfirm: () => dispatch(deleteStatus(status.get('id'), history, withRedraft)),
      }));
    }
  };

  handleEditClick = (status, history) => {
    this.props.dispatch(editStatus(status.get('id'), history));
  };

  handleDirectClick = (account, router) => {
    this.props.dispatch(directCompose(account, router));
  };

  handleMentionClick = (account, router) => {
    this.props.dispatch(mentionCompose(account, router));
  };

  handleOpenMedia = (media, index) => {
    this.props.dispatch(openModal('MEDIA', { statusId: this.props.status.get('id'), media, index }));
  };

  handleOpenVideo = (media, options) => {
    this.props.dispatch(openModal('VIDEO', { statusId: this.props.status.get('id'), media, options }));
  };

  handleHotkeyOpenMedia = e => {
    const { status } = this.props;

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        this.handleOpenVideo(status.getIn(['media_attachments', 0]), { startTime: 0 });
      } else {
        this.handleOpenMedia(status.get('media_attachments'), 0);
      }
    }
  };

  handleMuteClick = (account) => {
    this.props.dispatch(initMuteModal(account));
  };

  handleConversationMuteClick = (status) => {
    if (status.get('muted')) {
      this.props.dispatch(unmuteStatus(status.get('id')));
    } else {
      this.props.dispatch(muteStatus(status.get('id')));
    }
  };

  handleToggleHidden = (status) => {
    if (status.get('hidden')) {
      this.props.dispatch(revealStatus(status.get('id')));
    } else {
      this.props.dispatch(hideStatus(status.get('id')));
    }
  };

  handleToggleAll = () => {
    const { status, ancestorsIds, descendantsIds } = this.props;
    const statusIds = [status.get('id')].concat(ancestorsIds.toJS(), descendantsIds.toJS());

    if (status.get('hidden')) {
      this.props.dispatch(revealStatus(statusIds));
    } else {
      this.props.dispatch(hideStatus(statusIds));
    }
  };

  handleTranslate = status => {
    const { dispatch } = this.props;

    if (status.get('translation')) {
      dispatch(undoStatusTranslation(status.get('id')));
    } else {
      dispatch(translateStatus(status.get('id')));
    }
  };

  handleBlockClick = (status) => {
    const { dispatch } = this.props;
    const account = status.get('account');
    dispatch(initBlockModal(account));
  };

  handleReport = (status) => {
    this.props.dispatch(initReport(status.get('account'), status));
  };

  handleEmbed = (status) => {
    this.props.dispatch(openModal('EMBED', { url: status.get('url') }));
  };

  handleUnmuteClick = account => {
    this.props.dispatch(unmuteAccount(account.get('id')));
  };

  handleUnblockClick = account => {
    this.props.dispatch(unblockAccount(account.get('id')));
  };

  handleBlockDomainClick = domain => {
    this.props.dispatch(openModal('CONFIRM', {
      message: <FormattedMessage id='confirmations.domain_block.message' defaultMessage='Are you really, really sure you want to block the entire {domain}? In most cases a few targeted blocks or mutes are sufficient and preferable. You will not see content from that domain in any public timelines or your notifications. Your followers from that domain will be removed.' values={{ domain: <strong>{domain}</strong> }} />,
      confirm: this.props.intl.formatMessage(messages.blockDomainConfirm),
      onConfirm: () => this.props.dispatch(blockDomain(domain)),
    }));
  };

  handleUnblockDomainClick = domain => {
    this.props.dispatch(unblockDomain(domain));
  };


  handleHotkeyMoveUp = () => {
    this.handleMoveUp(this.props.status.get('id'));
  };

  handleHotkeyMoveDown = () => {
    this.handleMoveDown(this.props.status.get('id'));
  };

  handleHotkeyReply = e => {
    e.preventDefault();
    this.handleReplyClick(this.props.status);
  };

  handleHotkeyFavourite = () => {
    this.handleFavouriteClick(this.props.status);
  };

  handleHotkeyBoost = () => {
    this.handleReblogClick(this.props.status);
  };

  handleHotkeyMention = e => {
    e.preventDefault();
    this.handleMentionClick(this.props.status.get('account'));
  };

  handleHotkeyOpenProfile = () => {
    this.context.router.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
  };

  handleHotkeyToggleHidden = () => {
    this.handleToggleHidden(this.props.status);
  };

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  };

  handleMoveUp = id => {
    const { status, ancestorsIds, descendantsIds } = this.props;

    if (id === status.get('id')) {
      this._selectChild(ancestorsIds.size - 1, true);
    } else {
      let index = ancestorsIds.indexOf(id);

      if (index === -1) {
        index = descendantsIds.indexOf(id);
        this._selectChild(ancestorsIds.size + index, true);
      } else {
        this._selectChild(index - 1, true);
      }
    }
  };

  handleMoveDown = id => {
    const { status, ancestorsIds, descendantsIds } = this.props;

    if (id === status.get('id')) {
      this._selectChild(ancestorsIds.size + 1, false);
    } else {
      let index = ancestorsIds.indexOf(id);

      if (index === -1) {
        index = descendantsIds.indexOf(id);
        this._selectChild(ancestorsIds.size + index + 2, false);
      } else {
        this._selectChild(index + 1, false);
      }
    }
  };

  _selectChild (index, align_top) {
    const container = this.node;
    const element = container.querySelectorAll('.focusable')[index];

    if (element) {
      if (align_top && container.scrollTop > element.offsetTop) {
        element.scrollIntoView(true);
      } else if (!align_top && container.scrollTop + container.clientHeight < element.offsetTop + element.offsetHeight) {
        element.scrollIntoView(false);
      }
      element.focus();
    }
  }

  renderChildren (list) {
    return list.map(id => (
      <StatusContainer
        key={id}
        id={id}
        onMoveUp={this.handleMoveUp}
        onMoveDown={this.handleMoveDown}
        contextType='thread'
      />
    ));
  }

  setRef = c => {
    this.node = c;
  };

  componentDidUpdate () {
    if (this._scrolledIntoView) {
      return;
    }

    const { status, ancestorsIds } = this.props;

    if (status && ancestorsIds && ancestorsIds.size > 0) {
      const element = this.node.querySelectorAll('.focusable')[ancestorsIds.size - 1];

      window.requestAnimationFrame(() => {
        element.scrollIntoView(true);
      });
      this._scrolledIntoView = true;
    }
  }

  componentWillUnmount () {
    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  };

  render () {
    let ancestors, descendants;
    const { isLoading, status, ancestorsIds, descendantsIds, intl, domain, multiColumn, pictureInPicture } = this.props;
    const { fullscreen } = this.state;

    if (isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    if (status === null) {
      return (
        <Column>
          <ColumnBackButton multiColumn={multiColumn} />
          <MissingIndicator />
        </Column>
      );
    }

    if (ancestorsIds && ancestorsIds.size > 0) {
      ancestors = <div>{this.renderChildren(ancestorsIds)}</div>;
    }

    if (descendantsIds && descendantsIds.size > 0) {
      descendants = <div>{this.renderChildren(descendantsIds)}</div>;
    }

    const isLocal = status.getIn(['account', 'acct'], '').indexOf('@') === -1;
    const isIndexable = !status.getIn(['account', 'noindex']);

    const handlers = {
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleHotkeyMention,
      openProfile: this.handleHotkeyOpenProfile,
      toggleHidden: this.handleHotkeyToggleHidden,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
    };

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.detailedStatus)}>
        <ColumnHeader
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button type='button' className='column-header__button' title={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} aria-label={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} onClick={this.handleToggleAll}><Icon id={status.get('hidden') ? 'eye-slash' : 'eye'} /></button>
          )}
        />

        <ScrollContainer scrollKey='thread'>
          <div className={classNames('scrollable', { fullscreen })} ref={this.setRef}>
            {ancestors}

            <HotKeys handlers={handlers}>
              <div className={classNames('focusable', 'detailed-status__wrapper')} tabIndex='0' aria-label={textForScreenReader(intl, status, false)}>
                <DetailedStatus
                  key={`details-${status.get('id')}`}
                  status={status}
                  onOpenVideo={this.handleOpenVideo}
                  onOpenMedia={this.handleOpenMedia}
                  onToggleHidden={this.handleToggleHidden}
                  onTranslate={this.handleTranslate}
                  domain={domain}
                  showMedia={this.state.showMedia}
                  onToggleMediaVisibility={this.handleToggleMediaVisibility}
                  pictureInPicture={pictureInPicture}
                />

                <ActionBar
                  key={`action-bar-${status.get('id')}`}
                  status={status}
                  onReply={this.handleReplyClick}
                  onFavourite={this.handleFavouriteClick}
                  onReblog={this.handleReblogClick}
                  onBookmark={this.handleBookmarkClick}
                  onDelete={this.handleDeleteClick}
                  onEdit={this.handleEditClick}
                  onDirect={this.handleDirectClick}
                  onMention={this.handleMentionClick}
                  onMute={this.handleMuteClick}
                  onUnmute={this.handleUnmuteClick}
                  onMuteConversation={this.handleConversationMuteClick}
                  onBlock={this.handleBlockClick}
                  onUnblock={this.handleUnblockClick}
                  onBlockDomain={this.handleBlockDomainClick}
                  onUnblockDomain={this.handleUnblockDomainClick}
                  onReport={this.handleReport}
                  onPin={this.handlePin}
                  onEmbed={this.handleEmbed}
                />
              </div>
            </HotKeys>

            {descendants}
          </div>
        </ScrollContainer>

        <Helmet>
          <title>{titleFromStatus(status)}</title>
          <meta name='robots' content={(isLocal && isIndexable) ? 'all' : 'noindex'} />
        </Helmet>
      </Column>
    );
  }

}
