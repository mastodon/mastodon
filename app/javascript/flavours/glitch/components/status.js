import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import StatusPrepend from './status_prepend';
import StatusHeader from './status_header';
import StatusIcons from './status_icons';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import AttachmentList from './attachment_list';
import Card from '../features/status/components/card';
import { injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, Video, Audio } from 'flavours/glitch/util/async-components';
import { HotKeys } from 'react-hotkeys';
import NotificationOverlayContainer from 'flavours/glitch/features/notifications/containers/overlay_container';
import classNames from 'classnames';
import { autoUnfoldCW } from 'flavours/glitch/util/content_warning';
import PollContainer from 'flavours/glitch/containers/poll_container';
import { displayMedia } from 'flavours/glitch/util/initial_state';
import PictureInPicturePlaceholder from 'flavours/glitch/components/picture_in_picture_placeholder';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

export const textForScreenReader = (intl, status, rebloggedByText = false, expanded = false) => {
  const displayName = status.getIn(['account', 'display_name']);

  const values = [
    displayName.length === 0 ? status.getIn(['account', 'acct']).split('@')[0] : displayName,
    status.get('spoiler_text') && !expanded ? status.get('spoiler_text') : status.get('search_index').slice(status.get('spoiler_text').length),
    intl.formatDate(status.get('created_at'), { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }),
    status.getIn(['account', 'acct']),
  ];

  if (rebloggedByText) {
    values.push(rebloggedByText);
  }

  return values.join(', ');
};

export const defaultMediaVisibility = (status, settings) => {
  if (!status) {
    return undefined;
  }

  if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
    status = status.get('reblog');
  }

  if (settings.getIn(['media', 'reveal_behind_cw']) && !!status.get('spoiler_text')) {
    return true;
  }

  return (displayMedia !== 'hide_all' && !status.get('sensitive') || displayMedia === 'show_all');
}

export default @injectIntl
class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    containerId: PropTypes.string,
    id: PropTypes.string,
    status: ImmutablePropTypes.map,
    otherAccounts: ImmutablePropTypes.list,
    account: ImmutablePropTypes.map,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onBookmark: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onPin: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    muted: PropTypes.bool,
    collapse: PropTypes.bool,
    hidden: PropTypes.bool,
    unread: PropTypes.bool,
    prepend: PropTypes.string,
    withDismiss: PropTypes.bool,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
    getScrollPosition: PropTypes.func,
    updateScrollBottom: PropTypes.func,
    expanded: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    cacheMediaWidth: PropTypes.func,
    cachedMediaWidth: PropTypes.number,
    onClick: PropTypes.func,
    scrollKey: PropTypes.string,
    deployPictureInPicture: PropTypes.func,
    usingPiP: PropTypes.bool,
  };

  state = {
    isCollapsed: false,
    autoCollapsed: false,
    isExpanded: undefined,
    showMedia: undefined,
    statusId: undefined,
    revealBehindCW: undefined,
    showCard: false,
    forceFilter: undefined,
  }

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'settings',
    'prepend',
    'muted',
    'collapse',
    'notification',
    'hidden',
    'expanded',
    'unread',
    'usingPiP',
  ]

  updateOnStates = [
    'isExpanded',
    'isCollapsed',
    'showMedia',
    'forceFilter',
  ]

  //  If our settings have changed to disable collapsed statuses, then we
  //  need to make sure that we uncollapse every one. We do that by watching
  //  for changes to `settings.collapsed.enabled` in
  //  `getderivedStateFromProps()`.

  //  We also need to watch for changes on the `collapse` prop---if this
  //  changes to anything other than `undefined`, then we need to collapse or
  //  uncollapse our status accordingly.
  static getDerivedStateFromProps(nextProps, prevState) {
    let update = {};
    let updated = false;

    // Make sure the state mirrors props we track…
    if (nextProps.collapse !== prevState.collapseProp) {
      update.collapseProp = nextProps.collapse;
      updated = true;
    }
    if (nextProps.expanded !== prevState.expandedProp) {
      update.expandedProp = nextProps.expanded;
      updated = true;
    }

    // Update state based on new props
    if (!nextProps.settings.getIn(['collapsed', 'enabled'])) {
      if (prevState.isCollapsed) {
        update.isCollapsed = false;
        updated = true;
      }
    } else if (
      nextProps.collapse !== prevState.collapseProp &&
      nextProps.collapse !== undefined
    ) {
      update.isCollapsed = nextProps.collapse;
      if (nextProps.collapse) update.isExpanded = false;
      updated = true;
    }
    if (nextProps.expanded !== prevState.expandedProp &&
      nextProps.expanded !== undefined
    ) {
      update.isExpanded = nextProps.expanded;
      if (nextProps.expanded) update.isCollapsed = false;
      updated = true;
    }

    if (nextProps.expanded === undefined &&
      prevState.isExpanded === undefined &&
      update.isExpanded === undefined
    ) {
      const isExpanded = autoUnfoldCW(nextProps.settings, nextProps.status);
      if (isExpanded !== undefined) {
        update.isExpanded = isExpanded;
        updated = true;
      }
    }

    if (nextProps.status && nextProps.status.get('id') !== prevState.statusId) {
      update.showMedia = defaultMediaVisibility(nextProps.status, nextProps.settings);
      update.statusId = nextProps.status.get('id');
      updated = true;
    }

    if (nextProps.settings.getIn(['media', 'reveal_behind_cw']) !== prevState.revealBehindCW) {
      update.revealBehindCW = nextProps.settings.getIn(['media', 'reveal_behind_cw']);
      if (update.revealBehindCW) {
        update.showMedia = defaultMediaVisibility(nextProps.status, nextProps.settings);
      }
      updated = true;
    }

    return updated ? update : null;
  }

  //  When mounting, we just check to see if our status should be collapsed,
  //  and collapse it if so. We don't need to worry about whether collapsing
  //  is enabled here, because `setCollapsed()` already takes that into
  //  account.

  //  The cases where a status should be collapsed are:
  //
  //   -  The `collapse` prop has been set to `true`
  //   -  The user has decided in local settings to collapse all statuses.
  //   -  The user has decided to collapse all notifications ('muted'
  //      statuses).
  //   -  The user has decided to collapse long statuses and the status is
  //      over 400px (without media, or 650px with).
  //   -  The status is a reply and the user has decided to collapse all
  //      replies.
  //   -  The status contains media and the user has decided to collapse all
  //      statuses with media.
  //   -  The status is a reblog the user has decided to collapse all
  //      statuses which are reblogs.
  componentDidMount () {
    const { node } = this;
    const {
      status,
      settings,
      collapse,
      muted,
      prepend,
    } = this.props;

    // Prevent a crash when node is undefined. Not completely sure why this
    // happens, might be because status === null.
    if (node === undefined) return;

    const autoCollapseSettings = settings.getIn(['collapsed', 'auto']);

    if (function () {
      switch (true) {
      case !!collapse:
      case !!autoCollapseSettings.get('all'):
      case autoCollapseSettings.get('notifications') && !!muted:
      case autoCollapseSettings.get('lengthy') && node.clientHeight > (
        status.get('media_attachments').size && !muted ? 650 : 400
      ):
      case autoCollapseSettings.get('reblogs') && prepend === 'reblogged_by':
      case autoCollapseSettings.get('replies') && status.get('in_reply_to_id', null) !== null:
      case autoCollapseSettings.get('media') && !(status.get('spoiler_text').length) && !!status.get('media_attachments').size:
        return true;
      default:
        return false;
      }
    }()) {
      this.setCollapsed(true);
      // Hack to fix timeline jumps on second rendering when auto-collapsing
      this.setState({ autoCollapsed: true });
    }

    // Hack to fix timeline jumps when a preview card is fetched
    this.setState({
      showCard: !this.props.muted && !this.props.hidden && this.props.status && this.props.status.get('card') && this.props.settings.get('inline_preview_cards'),
    });
  }

  //  Hack to fix timeline jumps on second rendering when auto-collapsing
  //  or on subsequent rendering when a preview card has been fetched
  getSnapshotBeforeUpdate (prevProps, prevState) {
    if (!this.props.getScrollPosition) return null;

    const { muted, hidden, status, settings } = this.props;

    const doShowCard = !muted && !hidden && status && status.get('card') && settings.get('inline_preview_cards');
    if (this.state.autoCollapsed || (doShowCard && !this.state.showCard)) {
      if (doShowCard) this.setState({ showCard: true });
      if (this.state.autoCollapsed) this.setState({ autoCollapsed: false });
      return this.props.getScrollPosition();
    } else {
      return null;
    }
  }

  componentDidUpdate (prevProps, prevState, snapshot) {
    if (snapshot !== null && this.props.updateScrollBottom && this.node.offsetTop < snapshot.top) {
      this.props.updateScrollBottom(snapshot.height - snapshot.top);
    }
  }

  componentWillUnmount() {
    if (this.node && this.props.getScrollPosition) {
      const position = this.props.getScrollPosition();
      if (position !== null && this.node.offsetTop < position.top) {
         requestAnimationFrame(() => { this.props.updateScrollBottom(position.height - position.top); });
      }
    }
  }

  //  `setCollapsed()` sets the value of `isCollapsed` in our state, that is,
  //  whether the toot is collapsed or not.

  //  `setCollapsed()` automatically checks for us whether toot collapsing
  //  is enabled, so we don't have to.
  setCollapsed = (value) => {
    if (this.props.settings.getIn(['collapsed', 'enabled'])) {
      this.setState({ isCollapsed: value });
      if (value) {
        this.setExpansion(false);
      }
    } else {
      this.setState({ isCollapsed: false });
    }
  }

  setExpansion = (value) => {
    this.setState({ isExpanded: value });
    if (value) {
      this.setCollapsed(false);
    }
  }

  //  `parseClick()` takes a click event and responds appropriately.
  //  If our status is collapsed, then clicking on it should uncollapse it.
  //  If `Shift` is held, then clicking on it should collapse it.
  //  Otherwise, we open the url handed to us in `destination`, if
  //  applicable.
  parseClick = (e, destination) => {
    const { router } = this.context;
    const { status } = this.props;
    const { isCollapsed } = this.state;
    if (!router) return;

    if (e.button === 0 && !(e.ctrlKey || e.altKey || e.metaKey)) {
      if (isCollapsed) this.setCollapsed(false);
      else if (e.shiftKey) {
        this.setCollapsed(true);
        document.getSelection().removeAllRanges();
      } else if (this.props.onClick) {
        this.props.onClick();
        return;
      } else {
        if (destination === undefined) {
          destination = `/statuses/${
            status.getIn(['reblog', 'id'], status.get('id'))
          }`;
        }
        let state = {...router.history.location.state};
        state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
        router.history.push(destination, state);
      }
      e.preventDefault();
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0) {
      const id = e.currentTarget.getAttribute('data-id');
      e.preventDefault();
      let state = {...this.context.router.history.location.state};
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(`/accounts/${id}`, state);
    }
  }

  handleExpandedToggle = () => {
    if (this.props.status.get('spoiler_text')) {
      this.setExpansion(!this.state.isExpanded);
    }
  };

  handleOpenVideo = (media, options) => {
    this.props.onOpenVideo(media, options);
  }

  handleHotkeyOpenMedia = e => {
    const { status, onOpenMedia, onOpenVideo } = this.props;

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        // TODO: toggle play/paused?
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        onOpenVideo(status.getIn(['media_attachments', 0]), { startTime: 0 });
      } else {
        onOpenMedia(status.get('media_attachments'), 0);
      }
    }
  }

  handleDeployPictureInPicture = (type, mediaProps) => {
    const { deployPictureInPicture, status } = this.props;

    deployPictureInPicture(status, type, mediaProps);
  }

  handleHotkeyReply = e => {
    e.preventDefault();
    this.props.onReply(this.props.status, this.context.router.history);
  }

  handleHotkeyFavourite = (e) => {
    this.props.onFavourite(this.props.status, e);
  }

  handleHotkeyBoost = e => {
    this.props.onReblog(this.props.status, e);
  }

  handleHotkeyBookmark = e => {
    this.props.onBookmark(this.props.status, e);
  }

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleHotkeyOpen = () => {
    let state = {...this.context.router.history.location.state};
    state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
    this.context.router.history.push(`/statuses/${this.props.status.get('id')}`, state);
  }

  handleHotkeyOpenProfile = () => {
    let state = {...this.context.router.history.location.state};
    state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
    this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`, state);
  }

  handleHotkeyMoveUp = e => {
    this.props.onMoveUp(this.props.containerId || this.props.id, e.target.getAttribute('data-featured'));
  }

  handleHotkeyMoveDown = e => {
    this.props.onMoveDown(this.props.containerId || this.props.id, e.target.getAttribute('data-featured'));
  }

  handleHotkeyCollapse = e => {
    if (!this.props.settings.getIn(['collapsed', 'enabled']))
      return;

    this.setCollapsed(!this.state.isCollapsed);
  }

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  }

  handleUnfilterClick = e => {
    const { onUnfilter, status } = this.props;
    onUnfilter(status.get('reblog') ? status.get('reblog') : status, () => this.setState({ forceFilter: false }));
  }

  handleFilterClick = () => {
    this.setState({ forceFilter: true });
  }

  handleRef = c => {
    this.node = c;
  }

  renderLoadingMediaGallery () {
    return <div className='media-gallery' style={{ height: '110px' }} />;
  }

  renderLoadingVideoPlayer () {
    return <div className='video-player' style={{ height: '110px' }} />;
  }

  renderLoadingAudioPlayer () {
    return <div className='audio-player' style={{ height: '110px' }} />;
  }

  render () {
    const {
      handleRef,
      parseClick,
      setExpansion,
      setCollapsed,
    } = this;
    const { router } = this.context;
    const {
      intl,
      status,
      account,
      otherAccounts,
      settings,
      collapsed,
      muted,
      prepend,
      intersectionObserverWrapper,
      onOpenVideo,
      onOpenMedia,
      notification,
      hidden,
      unread,
      featured,
      usingPiP,
      ...other
    } = this.props;
    const { isExpanded, isCollapsed, forceFilter } = this.state;
    let background = null;
    let attachments = null;
    let media = null;
    let mediaIcon = null;

    if (status === null) {
      return null;
    }

    const handlers = {
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleHotkeyMention,
      open: this.handleHotkeyOpen,
      openProfile: this.handleHotkeyOpenProfile,
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      toggleSpoiler: this.handleExpandedToggle,
      bookmark: this.handleHotkeyBookmark,
      toggleCollapse: this.handleHotkeyCollapse,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
    };

    if (hidden) {
      return (
        <HotKeys handlers={handlers}>
          <div ref={this.handleRef} className='status focusable' tabIndex='0'>
            {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
            {' '}
            {status.get('content')}
          </div>
        </HotKeys>
      );
    }

    const filtered = (status.get('filtered') || status.getIn(['reblog', 'filtered'])) && settings.get('filtering_behavior') !== 'content_warning';
    if (forceFilter === undefined ? filtered : forceFilter) {
      const minHandlers = this.props.muted ? {} : {
        moveUp: this.handleHotkeyMoveUp,
        moveDown: this.handleHotkeyMoveDown,
      };

      return (
        <HotKeys handlers={minHandlers}>
          <div className='status__wrapper status__wrapper--filtered focusable' tabIndex='0' ref={this.handleRef}>
            <FormattedMessage id='status.filtered' defaultMessage='Filtered' />
            {settings.get('filtering_behavior') !== 'upstream' && ' '}
            {settings.get('filtering_behavior') !== 'upstream' && (
              <button className='status__wrapper--filtered__button' onClick={this.handleUnfilterClick}>
                <FormattedMessage id='status.show_filter_reason' defaultMessage='(show why)' />
              </button>
            )}
          </div>
        </HotKeys>
      );
    }

    //  If user backgrounds for collapsed statuses are enabled, then we
    //  initialize our background accordingly. This will only be rendered if
    //  the status is collapsed.
    if (settings.getIn(['collapsed', 'backgrounds', 'user_backgrounds'])) {
      background = status.getIn(['account', 'header']);
    }

    //  This handles our media attachments.
    //  If a media file is of unknwon type or if the status is muted
    //  (notification), we show a list of links instead of embedded media.

    //  After we have generated our appropriate media element and stored it in
    //  `media`, we snatch the thumbnail to use as our `background` if media
    //  backgrounds for collapsed statuses are enabled.
    attachments = status.get('media_attachments');
    if (status.get('poll')) {
      media = <PollContainer pollId={status.get('poll')} />;
      mediaIcon = 'tasks';
    } else if (usingPiP) {
      media = <PictureInPicturePlaceholder width={this.props.cachedMediaWidth} />;
      mediaIcon = 'video-camera';
    } else if (attachments.size > 0) {
      if (muted || attachments.some(item => item.get('type') === 'unknown')) {
        media = (
          <AttachmentList
            compact
            media={status.get('media_attachments')}
          />
        );
      } else if (attachments.getIn([0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
            {Component => (
              <Component
                src={attachment.get('url')}
                alt={attachment.get('description')}
                poster={attachment.get('preview_url') || status.getIn(['account', 'avatar_static'])}
                backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
                foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
                accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
                duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
                width={this.props.cachedMediaWidth}
                height={110}
                cacheWidth={this.props.cacheMediaWidth}
                deployPictureInPicture={this.handleDeployPictureInPicture}
              />
            )}
          </Bundle>
        );
        mediaIcon = 'music';
      } else if (attachments.getIn([0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (<Component
              preview={attachment.get('preview_url')}
              blurhash={attachment.get('blurhash')}
              src={attachment.get('url')}
              alt={attachment.get('description')}
              inline
              sensitive={status.get('sensitive')}
              letterbox={settings.getIn(['media', 'letterbox'])}
              fullwidth={settings.getIn(['media', 'fullwidth'])}
              preventPlayback={isCollapsed || !isExpanded}
              onOpenVideo={this.handleOpenVideo}
              width={this.props.cachedMediaWidth}
              cacheWidth={this.props.cacheMediaWidth}
              deployPictureInPicture={this.handleDeployPictureInPicture}
              visible={this.state.showMedia}
              onToggleVisibility={this.handleToggleMediaVisibility}
            />)}
          </Bundle>
        );
        mediaIcon = 'video-camera';
      } else {  //  Media type is 'image' or 'gifv'
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery}>
            {Component => (
              <Component
                media={attachments}
                sensitive={status.get('sensitive')}
                letterbox={settings.getIn(['media', 'letterbox'])}
                fullwidth={settings.getIn(['media', 'fullwidth'])}
                hidden={isCollapsed || !isExpanded}
                onOpenMedia={this.props.onOpenMedia}
                cacheWidth={this.props.cacheMediaWidth}
                defaultWidth={this.props.cachedMediaWidth}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
              />
            )}
          </Bundle>
        );
        mediaIcon = 'picture-o';
      }

      if (!status.get('sensitive') && !(status.get('spoiler_text').length > 0) && settings.getIn(['collapsed', 'backgrounds', 'preview_images'])) {
        background = attachments.getIn([0, 'preview_url']);
      }
    } else if (status.get('card') && settings.get('inline_preview_cards')) {
      media = (
        <Card
          onOpenMedia={this.props.onOpenMedia}
          card={status.get('card')}
          compact
          cacheWidth={this.props.cacheMediaWidth}
          defaultWidth={this.props.cachedMediaWidth}
          sensitive={status.get('sensitive')}
        />
      );
      mediaIcon = 'link';
    }

    //  Here we prepare extra data-* attributes for CSS selectors.
    //  Users can use those for theming, hiding avatars etc via UserStyle
    const selectorAttribs = {
      'data-status-by': `@${status.getIn(['account', 'acct'])}`,
    };

    if (prepend && account) {
      const notifKind = {
        favourite: 'favourited',
        reblog: 'boosted',
        reblogged_by: 'boosted',
        status: 'posted',
      }[prepend];

      selectorAttribs[`data-${notifKind}-by`] = `@${account.get('acct')}`;
    }

    let rebloggedByText;

    if (prepend === 'reblog') {
      rebloggedByText = intl.formatMessage({ id: 'status.reblogged_by', defaultMessage: '{name} boosted' }, { name: account.get('acct') });
    }

    const computedClass = classNames('status', `status-${status.get('visibility')}`, {
      collapsed: isCollapsed,
      'has-background': isCollapsed && background,
      'status__wrapper-reply': !!status.get('in_reply_to_id'),
      unread,
      muted,
    }, 'focusable');

    return (
      <HotKeys handlers={handlers}>
        <div
          className={computedClass}
          style={isCollapsed && background ? { backgroundImage: `url(${background})` } : null}
          {...selectorAttribs}
          ref={handleRef}
          tabIndex='0'
          data-featured={featured ? 'true' : null}
          aria-label={textForScreenReader(intl, status, rebloggedByText, !status.get('hidden'))}
        >
          <header className='status__info'>
            <span>
              {prepend && account ? (
                <StatusPrepend
                  type={prepend}
                  account={account}
                  parseClick={parseClick}
                  notificationId={this.props.notificationId}
                />
              ) : null}
              {!muted || !isCollapsed ? (
                <StatusHeader
                  status={status}
                  friend={account}
                  collapsed={isCollapsed}
                  parseClick={parseClick}
                  otherAccounts={otherAccounts}
                />
              ) : null}
            </span>
            <StatusIcons
              status={status}
              mediaIcon={mediaIcon}
              collapsible={settings.getIn(['collapsed', 'enabled'])}
              collapsed={isCollapsed}
              setCollapsed={setCollapsed}
              directMessage={!!otherAccounts}
            />
          </header>
          <StatusContent
            status={status}
            media={media}
            mediaIcon={mediaIcon}
            expanded={isExpanded}
            onExpandedToggle={this.handleExpandedToggle}
            parseClick={parseClick}
            disabled={!router}
            tagLinks={settings.get('tag_misleading_links')}
            rewriteMentions={settings.get('rewrite_mentions')}
          />
          {!isCollapsed || !(muted || !settings.getIn(['collapsed', 'show_action_bar'])) ? (
            <StatusActionBar
              {...other}
              status={status}
              account={status.get('account')}
              showReplyCount={settings.get('show_reply_count')}
              directMessage={!!otherAccounts}
              onFilter={this.handleFilterClick}
            />
          ) : null}
          {notification ? (
            <NotificationOverlayContainer
              notification={notification}
            />
          ) : null}
        </div>
      </HotKeys>
    );
  }

}
