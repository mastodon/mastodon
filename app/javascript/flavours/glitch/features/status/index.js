import Immutable from 'immutable';
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { createSelector } from 'reselect';
import { fetchStatus } from 'flavours/glitch/actions/statuses';
import MissingIndicator from 'flavours/glitch/components/missing_indicator';
import DetailedStatus from './components/detailed_status';
import ActionBar from './components/action_bar';
import Column from 'flavours/glitch/features/ui/components/column';
import {
  favourite,
  unfavourite,
  bookmark,
  unbookmark,
  reblog,
  unreblog,
  pin,
  unpin,
} from 'flavours/glitch/actions/interactions';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from 'flavours/glitch/actions/compose';
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { muteStatus, unmuteStatus, deleteStatus } from 'flavours/glitch/actions/statuses';
import { initMuteModal } from 'flavours/glitch/actions/mutes';
import { initBlockModal } from 'flavours/glitch/actions/blocks';
import { initReport } from 'flavours/glitch/actions/reports';
import { makeGetStatus } from 'flavours/glitch/selectors';
import { ScrollContainer } from 'react-router-scroll-4';
import ColumnBackButton from 'flavours/glitch/components/column_back_button';
import ColumnHeader from '../../components/column_header';
import StatusContainer from 'flavours/glitch/containers/status_container';
import { openModal } from 'flavours/glitch/actions/modal';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { HotKeys } from 'react-hotkeys';
import { boostModal, favouriteModal, deleteModal } from 'flavours/glitch/util/initial_state';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from 'flavours/glitch/util/fullscreen';
import { autoUnfoldCW } from 'flavours/glitch/util/content_warning';
import { textForScreenReader, defaultMediaVisibility } from 'flavours/glitch/components/status';
import Icon from 'flavours/glitch/components/icon';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? You will lose all replies, boosts and favourites to it.' },
  revealAll: { id: 'status.show_more_all', defaultMessage: 'Show more for all' },
  hideAll: { id: 'status.show_less_all', defaultMessage: 'Show less for all' },
  detailedStatus: { id: 'status.detailed_status', defaultMessage: 'Detailed conversation view' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
  tootHeading: { id: 'column.toot', defaultMessage: 'Toots and replies' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const getAncestorsIds = createSelector([
    (_, { id }) => id,
    state => state.getIn(['contexts', 'inReplyTos']),
  ], (statusId, inReplyTos) => {
    let ancestorsIds = Immutable.List();
    ancestorsIds = ancestorsIds.withMutations(mutable => {
      let id = statusId;

      while (id) {
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
      let id        = ids.shift();
      const replies = contextReplies.get(id);

      if (statusId !== id) {
        descendantsIds.push(id);
      }

      if (replies) {
        replies.reverse().forEach(reply => {
          ids.unshift(reply);
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
    let ancestorsIds = Immutable.List();
    let descendantsIds = Immutable.List();

    if (status) {
      ancestorsIds = getAncestorsIds(state, { id: status.get('in_reply_to_id') });
      descendantsIds = getDescendantsIds(state, { id: status.get('id') });
    }

    return {
      status,
      ancestorsIds,
      descendantsIds,
      settings: state.get('local_settings'),
      askReplyConfirmation: state.getIn(['local_settings', 'confirm_before_clearing_draft']) && state.getIn(['compose', 'text']).trim().length !== 0,
      domain: state.getIn(['meta', 'domain']),
    };
  };

  return mapStateToProps;
};

export default @injectIntl
@connect(makeMapStateToProps)
class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    settings: ImmutablePropTypes.map.isRequired,
    ancestorsIds: ImmutablePropTypes.list,
    descendantsIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    askReplyConfirmation: PropTypes.bool,
    multiColumn: PropTypes.bool,
    domain: PropTypes.string.isRequired,
  };

  state = {
    fullscreen: false,
    isExpanded: undefined,
    threadExpanded: undefined,
    statusId: undefined,
    loadedStatusId: undefined,
    showMedia: undefined,
    revealBehindCW: undefined,
  };

  componentDidMount () {
    attachFullscreenListener(this.onFullScreenChange);
    this.props.dispatch(fetchStatus(this.props.params.statusId));

    const { status, ancestorsIds } = this.props;

    if (status && ancestorsIds && ancestorsIds.size > 0) {
      const element = this.node.querySelectorAll('.focusable')[ancestorsIds.size - 1];

      window.requestAnimationFrame(() => {
        element.scrollIntoView(true);
      });
    }
  }

  static getDerivedStateFromProps(props, state) {
    let update = {};
    let updated = false;

    if (props.params.statusId && state.statusId !== props.params.statusId) {
      props.dispatch(fetchStatus(props.params.statusId));
      update.threadExpanded = undefined;
      update.statusId = props.params.statusId;
      updated = true;
    }

    const revealBehindCW = props.settings.getIn(['media', 'reveal_behind_cw']);
    if (revealBehindCW !== state.revealBehindCW) {
      update.revealBehindCW = revealBehindCW;
      if (revealBehindCW) update.showMedia = defaultMediaVisibility(props.status, props.settings);
      updated = true;
    }

    if (props.status && state.loadedStatusId !== props.status.get('id')) {
      update.showMedia = defaultMediaVisibility(props.status, props.settings);
      update.loadedStatusId = props.status.get('id');
      update.isExpanded = autoUnfoldCW(props.settings, props.status);
      updated = true;
    }

    return updated ? update : null;
  }

  handleExpandedToggle = () => {
    if (this.props.status.get('spoiler_text')) {
      this.setExpansion(!this.state.isExpanded);
    }
  };

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  }

  handleModalFavourite = (status) => {
    this.props.dispatch(favourite(status));
  }

  handleFavouriteClick = (status, e) => {
    if (status.get('favourited')) {
      this.props.dispatch(unfavourite(status));
    } else {
      if ((e && e.shiftKey) || !favouriteModal) {
        this.handleModalFavourite(status);
      } else {
        this.props.dispatch(openModal('FAVOURITE', { status, onFavourite: this.handleModalFavourite }));
      }
    }
  }

  handlePin = (status) => {
    if (status.get('pinned')) {
      this.props.dispatch(unpin(status));
    } else {
      this.props.dispatch(pin(status));
    }
  }

  handleReplyClick = (status) => {
    let { askReplyConfirmation, dispatch, intl } = this.props;
    if (askReplyConfirmation) {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(messages.replyMessage),
        confirm: intl.formatMessage(messages.replyConfirm),
        onDoNotAsk: () => dispatch(changeLocalSetting(['confirm_before_clearing_draft'], false)),
        onConfirm: () => dispatch(replyCompose(status, this.context.router.history)),
      }));
    } else {
      dispatch(replyCompose(status, this.context.router.history));
    }
  }

  handleModalReblog = (status) => {
    const { dispatch } = this.props;

    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status));
    }
  }

  handleReblogClick = (status, e) => {
    const { settings, dispatch } = this.props;

    if (settings.get('confirm_boost_missing_media_description') && status.get('media_attachments').some(item => !item.get('description')) && !status.get('reblogged')) {
      dispatch(openModal('BOOST', { status, onReblog: this.handleModalReblog, missingMediaDescription: true }));
    } else if ((e && e.shiftKey) || !boostModal) {
      this.handleModalReblog(status);
    } else {
      dispatch(openModal('BOOST', { status, onReblog: this.handleModalReblog }));
    }
  }

  handleBookmarkClick = (status) => {
    if (status.get('bookmarked')) {
      this.props.dispatch(unbookmark(status));
    } else {
      this.props.dispatch(bookmark(status));
    }
  }

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
  }

  handleDirectClick = (account, router) => {
    this.props.dispatch(directCompose(account, router));
  }

  handleMentionClick = (account, router) => {
    this.props.dispatch(mentionCompose(account, router));
  }

  handleOpenMedia = (media, index) => {
    this.props.dispatch(openModal('MEDIA', { media, index }));
  }

  handleOpenVideo = (media, options) => {
    this.props.dispatch(openModal('VIDEO', { media, options }));
  }

  handleHotkeyOpenMedia = e => {
    const { status } = this.props;

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        // TODO: toggle play/paused?
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        this.handleOpenVideo(status.getIn(['media_attachments', 0]), { startTime: 0 });
      } else {
        this.handleOpenMedia(status.get('media_attachments'), 0);
      }
    }
  }

  handleMuteClick = (account) => {
    this.props.dispatch(initMuteModal(account));
  }

  handleConversationMuteClick = (status) => {
    if (status.get('muted')) {
      this.props.dispatch(unmuteStatus(status.get('id')));
    } else {
      this.props.dispatch(muteStatus(status.get('id')));
    }
  }

  handleToggleAll = () => {
    const { isExpanded } = this.state;
    this.setState({ isExpanded: !isExpanded, threadExpanded: !isExpanded });
  }

  handleBlockClick = (status) => {
    const { dispatch } = this.props;
    const account = status.get('account');
    dispatch(initBlockModal(account));
  }

  handleReport = (status) => {
    this.props.dispatch(initReport(status.get('account'), status));
  }

  handleEmbed = (status) => {
    this.props.dispatch(openModal('EMBED', { url: status.get('url') }));
  }

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  }

  handleHotkeyMoveUp = () => {
    this.handleMoveUp(this.props.status.get('id'));
  }

  handleHotkeyMoveDown = () => {
    this.handleMoveDown(this.props.status.get('id'));
  }

  handleHotkeyReply = e => {
    e.preventDefault();
    this.handleReplyClick(this.props.status);
  }

  handleHotkeyFavourite = () => {
    this.handleFavouriteClick(this.props.status);
  }

  handleHotkeyBoost = () => {
    this.handleReblogClick(this.props.status);
  }

  handleHotkeyBookmark = () => {
    this.handleBookmarkClick(this.props.status);
  }

  handleHotkeyMention = e => {
    e.preventDefault();
    this.handleMentionClick(this.props.status);
  }

  handleHotkeyOpenProfile = () => {
    let state = {...this.context.router.history.location.state};
    state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
    this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`, state);
  }

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
  }

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
  }

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

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  renderChildren (list) {
    return list.map(id => (
      <StatusContainer
        key={id}
        id={id}
        expanded={this.state.threadExpanded}
        onMoveUp={this.handleMoveUp}
        onMoveDown={this.handleMoveDown}
        contextType='thread'
      />
    ));
  }

  setExpansion = value => {
    this.setState({ isExpanded: value });
  }

  setRef = c => {
    this.node = c;
  }

  setColumnRef = c => {
    this.column = c;
  }

  componentDidUpdate (prevProps) {
    if (this.props.params.statusId && (this.props.params.statusId !== prevProps.params.statusId || prevProps.ancestorsIds.size < this.props.ancestorsIds.size)) {
      const { status, ancestorsIds } = this.props;

      if (status && ancestorsIds && ancestorsIds.size > 0) {
        const element = this.node.querySelectorAll('.focusable')[ancestorsIds.size - 1];

        window.requestAnimationFrame(() => {
          element.scrollIntoView(true);
        });
      }
    }
  }

  componentWillUnmount () {
    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  }

  shouldUpdateScroll = (prevRouterProps, { location }) => {
    if ((((prevRouterProps || {}).location || {}).state || {}).mastodonModalOpen) return false;
    return !(location.state && location.state.mastodonModalOpen);
  }

  render () {
    let ancestors, descendants;
    const { setExpansion } = this;
    const { status, settings, ancestorsIds, descendantsIds, intl, domain, multiColumn } = this.props;
    const { fullscreen, isExpanded } = this.state;

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

    const handlers = {
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      bookmark: this.handleHotkeyBookmark,
      mention: this.handleHotkeyMention,
      openProfile: this.handleHotkeyOpenProfile,
      toggleSpoiler: this.handleExpandedToggle,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
    };

    return (
      <Column bindToDocument={!multiColumn} ref={this.setColumnRef} label={intl.formatMessage(messages.detailedStatus)}>
        <ColumnHeader
          icon='comment'
          title={intl.formatMessage(messages.tootHeading)}
          onClick={this.handleHeaderClick}
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button className='column-header__button' title={intl.formatMessage(!isExpanded ? messages.revealAll : messages.hideAll)} aria-label={intl.formatMessage(!isExpanded ? messages.revealAll : messages.hideAll)} onClick={this.handleToggleAll} aria-pressed={!isExpanded ? 'false' : 'true'}><Icon id={status.get('hidden') ? 'eye-slash' : 'eye'} /></button>
          )}
        />

        <ScrollContainer scrollKey='thread' shouldUpdateScroll={this.shouldUpdateScroll}>
          <div className={classNames('scrollable', 'detailed-status__wrapper', { fullscreen })} ref={this.setRef}>
            {ancestors}

            <HotKeys handlers={handlers}>
              <div className='focusable' tabIndex='0' aria-label={textForScreenReader(intl, status, false, !status.get('hidden'))}>
                <DetailedStatus
                  key={`details-${status.get('id')}`}
                  status={status}
                  settings={settings}
                  onOpenVideo={this.handleOpenVideo}
                  onOpenMedia={this.handleOpenMedia}
                  expanded={isExpanded}
                  onToggleHidden={this.handleExpandedToggle}
                  domain={domain}
                  showMedia={this.state.showMedia}
                  onToggleMediaVisibility={this.handleToggleMediaVisibility}
                />

                <ActionBar
                  key={`action-bar-${status.get('id')}`}
                  status={status}
                  onReply={this.handleReplyClick}
                  onFavourite={this.handleFavouriteClick}
                  onReblog={this.handleReblogClick}
                  onBookmark={this.handleBookmarkClick}
                  onDelete={this.handleDeleteClick}
                  onDirect={this.handleDirectClick}
                  onMention={this.handleMentionClick}
                  onMute={this.handleMuteClick}
                  onMuteConversation={this.handleConversationMuteClick}
                  onBlock={this.handleBlockClick}
                  onReport={this.handleReport}
                  onPin={this.handlePin}
                  onEmbed={this.handleEmbed}
                />
              </div>
            </HotKeys>

            {descendants}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
