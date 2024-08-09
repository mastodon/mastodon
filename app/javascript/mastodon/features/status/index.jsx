import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';
import { Helmet } from 'react-helmet';
import { withRouter } from 'react-router-dom';

import { createSelector } from '@reduxjs/toolkit';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { HotKeys } from 'react-hotkeys';

import VisibilityIcon from '@/material-icons/400-24px/visibility.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import { Icon }  from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { TimelineHint } from 'mastodon/components/timeline_hint';
import ScrollContainer from 'mastodon/containers/scroll_container';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import {
  unblockAccount,
  unmuteAccount,
} from '../../actions/accounts';
import { initBlockModal } from '../../actions/blocks';
import {
  replyCompose,
  mentionCompose,
  directCompose,
} from '../../actions/compose';
import {
  initDomainBlockModal,
  unblockDomain,
} from '../../actions/domain_blocks';
import {
  toggleFavourite,
  bookmark,
  unbookmark,
  toggleReblog,
  pin,
  unpin,
} from '../../actions/interactions';
import { openModal } from '../../actions/modal';
import { initMuteModal } from '../../actions/mutes';
import { initReport } from '../../actions/reports';
import {
  fetchStatus,
  muteStatus,
  unmuteStatus,
  deleteStatus,
  editStatus,
  hideStatus,
  revealStatus,
  translateStatus,
  undoStatusTranslation,
} from '../../actions/statuses';
import ColumnHeader from '../../components/column_header';
import { textForScreenReader, defaultMediaVisibility } from '../../components/status';
import StatusContainer from '../../containers/status_container';
import { deleteModal } from '../../initial_state';
import { makeGetStatus, makeGetPictureInPicture } from '../../selectors';
import Column from '../ui/components/column';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from '../ui/util/fullscreen';

import ActionBar from './components/action_bar';
import DetailedStatus from './components/detailed_status';


const messages = defineMessages({
  revealAll: { id: 'status.show_more_all', defaultMessage: 'Show more for all' },
  hideAll: { id: 'status.show_less_all', defaultMessage: 'Show less for all' },
  statusTitleWithAttachments: { id: 'status.title.with_attachments', defaultMessage: '{user} posted {attachmentCount, plural, one {an attachment} other {# attachments}}' },
  detailedStatus: { id: 'status.detailed_status', defaultMessage: 'Detailed conversation view' },
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
  const arr = Array.from(str);
  if (arr.length > num) {
    return arr.slice(0, num).join('') + '…';
  } else {
    return str;
  }
};

const titleFromStatus = (intl, status) => {
  const displayName = status.getIn(['account', 'display_name']);
  const username = status.getIn(['account', 'username']);
  const user = displayName.trim().length === 0 ? username : displayName;
  const text = status.get('search_index');
  const attachmentCount = status.get('media_attachments').size;

  return text ? `${user}: "${truncate(text, 30)}"` : intl.formatMessage(messages.statusTitleWithAttachments, { user, attachmentCount });
};

class Status extends ImmutablePureComponent {
  static propTypes = {
    identity: identityContextPropShape,
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    isLoading: PropTypes.bool,
    ancestorsIds: ImmutablePropTypes.list.isRequired,
    descendantsIds: ImmutablePropTypes.list.isRequired,
    intl: PropTypes.object.isRequired,
    askReplyConfirmation: PropTypes.bool,
    multiColumn: PropTypes.bool,
    domain: PropTypes.string.isRequired,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
    ...WithRouterPropTypes
  };

  state = {
    fullscreen: false,
    showMedia: defaultMediaVisibility(this.props.status),
    loadedStatusId: undefined,
  };

  UNSAFE_componentWillMount () {
    this.props.dispatch(fetchStatus(this.props.params.statusId));
  }

  componentDidMount () {
    attachFullscreenListener(this.onFullScreenChange);

    this._scrollStatusIntoView();
  }

  UNSAFE_componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchStatus(nextProps.params.statusId));
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
    const { signedIn } = this.props.identity;

    if (signedIn) {
      dispatch(toggleFavourite(status.get('id')));
    } else {
      dispatch(openModal({
        modalType: 'INTERACTION',
        modalProps: {
          type: 'favourite',
          accountId: status.getIn(['account', 'id']),
          url: status.get('uri'),
        },
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
    const { askReplyConfirmation, dispatch } = this.props;
    const { signedIn } = this.props.identity;

    if (signedIn) {
      if (askReplyConfirmation) {
        dispatch(openModal({ modalType: 'CONFIRM_REPLY', modalProps: { status } }));
      } else {
        dispatch(replyCompose(status));
      }
    } else {
      dispatch(openModal({
        modalType: 'INTERACTION',
        modalProps: {
          type: 'reply',
          accountId: status.getIn(['account', 'id']),
          url: status.get('uri'),
        },
      }));
    }
  };

  handleReblogClick = (status, e) => {
    const { dispatch } = this.props;
    const { signedIn } = this.props.identity;

    if (signedIn) {
      dispatch(toggleReblog(status.get('id'), e && e.shiftKey));
    } else {
      dispatch(openModal({
        modalType: 'INTERACTION',
        modalProps: {
          type: 'reblog',
          accountId: status.getIn(['account', 'id']),
          url: status.get('uri'),
        },
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

  handleDeleteClick = (status, withRedraft = false) => {
    const { dispatch } = this.props;

    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), withRedraft));
    } else {
      dispatch(openModal({ modalType: 'CONFIRM_DELETE_STATUS', modalProps: { statusId: status.get('id'), withRedraft } }));
    }
  };

  handleEditClick = (status) => {
    const { dispatch, askReplyConfirmation } = this.props;

    if (askReplyConfirmation) {
      dispatch(openModal({ modalType: 'CONFIRM_EDIT_STATUS', modalProps: { statusId: status.get('id') } }));
    } else {
      dispatch(editStatus(status.get('id')));
    }
  };

  handleDirectClick = (account) => {
    this.props.dispatch(directCompose(account));
  };

  handleMentionClick = (account) => {
    this.props.dispatch(mentionCompose(account));
  };

  handleOpenMedia = (media, index, lang) => {
    this.props.dispatch(openModal({
      modalType: 'MEDIA',
      modalProps: { statusId: this.props.status.get('id'), media, index, lang },
    }));
  };

  handleOpenVideo = (media, lang, options) => {
    this.props.dispatch(openModal({
      modalType: 'VIDEO',
      modalProps: { statusId: this.props.status.get('id'), media, lang, options },
    }));
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
      dispatch(undoStatusTranslation(status.get('id'), status.get('poll')));
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
    this.props.dispatch(openModal({
      modalType: 'EMBED',
      modalProps: { id: status.get('id') },
    }));
  };

  handleUnmuteClick = account => {
    this.props.dispatch(unmuteAccount(account.get('id')));
  };

  handleUnblockClick = account => {
    this.props.dispatch(unblockAccount(account.get('id')));
  };

  handleBlockDomainClick = account => {
    this.props.dispatch(initDomainBlockModal(account));
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
    this.props.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
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

  renderChildren (list, ancestors) {
    const { params: { statusId } } = this.props;

    return list.map((id, i) => (
      <StatusContainer
        key={id}
        id={id}
        onMoveUp={this.handleMoveUp}
        onMoveDown={this.handleMoveDown}
        contextType='thread'
        previousId={i > 0 ? list.get(i - 1) : undefined}
        nextId={list.get(i + 1) || (ancestors && statusId)}
        rootId={statusId}
      />
    ));
  }

  setContainerRef = c => {
    this.node = c;
  };

  setStatusRef = c => {
    this.statusNode = c;
  };

  _scrollStatusIntoView () {
    const { status, multiColumn } = this.props;

    if (status) {
      requestIdleCallback(() => {
        this.statusNode?.scrollIntoView(true);

        // In the single-column interface, `scrollIntoView` will put the post behind the header,
        // so compensate for that.
        if (!multiColumn) {
          const offset = document.querySelector('.column-header__wrapper')?.getBoundingClientRect()?.bottom;
          if (offset) {
            const scrollingElement = document.scrollingElement || document.body;
            scrollingElement.scrollBy(0, -offset);
          }
        }
      });
    }
  }

  componentDidUpdate (prevProps) {
    const { status, ancestorsIds } = this.props;

    if (status && (ancestorsIds.size > prevProps.ancestorsIds.size || prevProps.status?.get('id') !== status.get('id'))) {
      this._scrollStatusIntoView();
    }
  }

  componentWillUnmount () {
    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  };

  shouldUpdateScroll = (prevRouterProps, { location }) => {
    // Do not change scroll when opening a modal
    if (location.state?.mastodonModalKey !== prevRouterProps?.location?.state?.mastodonModalKey) {
      return false;
    }

    // Scroll to focused post if it is loaded
    if (this.statusNode) {
      return [0, this.statusNode.offsetTop];
    }

    // Do not scroll otherwise, `componentDidUpdate` will take care of that
    return false;
  };

  render () {
    let ancestors, descendants, remoteHint;
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
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    if (ancestorsIds && ancestorsIds.size > 0) {
      ancestors = <>{this.renderChildren(ancestorsIds, true)}</>;
    }

    if (descendantsIds && descendantsIds.size > 0) {
      descendants = <>{this.renderChildren(descendantsIds)}</>;
    }

    const isLocal = status.getIn(['account', 'acct'], '').indexOf('@') === -1;
    const isIndexable = !status.getIn(['account', 'noindex']);

    if (!isLocal) {
      remoteHint = <TimelineHint url={status.get('url')} resource={<FormattedMessage id='timeline_hint.resources.replies' defaultMessage='Some replies' />} />;
    }

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
            <button type='button' className='column-header__button' title={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} aria-label={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} onClick={this.handleToggleAll}><Icon id={status.get('hidden') ? 'eye-slash' : 'eye'} icon={status.get('hidden') ? VisibilityOffIcon : VisibilityIcon} /></button>
          )}
        />

        <ScrollContainer scrollKey='thread' shouldUpdateScroll={this.shouldUpdateScroll}>
          <div className={classNames('scrollable', { fullscreen })} ref={this.setContainerRef}>
            {ancestors}

            <HotKeys handlers={handlers}>
              <div className={classNames('focusable', 'detailed-status__wrapper', `detailed-status__wrapper-${status.get('visibility')}`)} tabIndex={0} aria-label={textForScreenReader(intl, status, false)} ref={this.setStatusRef}>
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
            {remoteHint}
          </div>
        </ScrollContainer>

        <Helmet>
          <title>{titleFromStatus(intl, status)}</title>
          <meta name='robots' content={(isLocal && isIndexable) ? 'all' : 'noindex'} />
          <link rel='canonical' href={status.get('url')} />
        </Helmet>
      </Column>
    );
  }

}

export default withRouter(injectIntl(connect(makeMapStateToProps)(withIdentity(Status))));
