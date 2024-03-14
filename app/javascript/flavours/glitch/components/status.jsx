import PropTypes from 'prop-types';

import { injectIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { HotKeys } from 'react-hotkeys';

import PictureInPicturePlaceholder from 'flavours/glitch/components/picture_in_picture_placeholder';
import PollContainer from 'flavours/glitch/containers/poll_container';
import NotificationOverlayContainer from 'flavours/glitch/features/notifications/containers/overlay_container';
import { autoUnfoldCW } from 'flavours/glitch/utils/content_warning';
import { withOptionalRouter, WithOptionalRouterPropTypes } from 'flavours/glitch/utils/react_router';

import Card from '../features/status/components/card';
// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';
import { MediaGallery, Video, Audio } from '../features/ui/util/async-components';
import { SensitiveMediaContext } from '../features/ui/util/sensitive_media_context';
import { displayMedia } from '../initial_state';

import AttachmentList from './attachment_list';
import { CollapseButton } from './collapse_button';
import { getHashtagBarForStatus } from './hashtag_bar';
import StatusActionBar from './status_action_bar';
import StatusContent from './status_content';
import StatusHeader from './status_header';
import StatusIcons from './status_icons';
import StatusPrepend from './status_prepend';

const domParser = new DOMParser();

export const textForScreenReader = (intl, status, rebloggedByText = false, expanded = false) => {
  const displayName = status.getIn(['account', 'display_name']);

  const spoilerText = status.getIn(['translation', 'spoiler_text']) || status.get('spoiler_text');
  const contentHtml = status.getIn(['translation', 'contentHtml']) || status.get('contentHtml');
  const contentText = domParser.parseFromString(contentHtml, 'text/html').documentElement.textContent;

  const values = [
    displayName.length === 0 ? status.getIn(['account', 'acct']).split('@')[0] : displayName,
    spoilerText && !expanded ? spoilerText : contentText,
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
};

class Status extends ImmutablePureComponent {

  static contextType = SensitiveMediaContext;

  static propTypes = {
    containerId: PropTypes.string,
    id: PropTypes.string,
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.record,
    previousId: PropTypes.string,
    nextInReplyToId: PropTypes.string,
    rootId: PropTypes.string,
    onClick: PropTypes.func,
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
    onAddFilter: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    onToggleHidden: PropTypes.func,
    onTranslate: PropTypes.func,
    onInteractionModal: PropTypes.func,
    muted: PropTypes.bool,
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
    scrollKey: PropTypes.string,
    deployPictureInPicture: PropTypes.func,
    settings: ImmutablePropTypes.map.isRequired,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
    ...WithOptionalRouterPropTypes,
  };

  state = {
    isCollapsed: false,
    autoCollapsed: false,
    isExpanded: undefined,
    showMedia: defaultMediaVisibility(this.props.status, this.props.settings) && !(this.context?.hideMediaByDefault),
    revealBehindCW: undefined,
    showCard: false,
    forceFilter: undefined,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'settings',
    'prepend',
    'muted',
    'notification',
    'hidden',
    'expanded',
    'unread',
    'pictureInPicture',
    'previousId',
    'nextInReplyToId',
    'rootId',
  ];

  updateOnStates = [
    'isExpanded',
    'isCollapsed',
    'showMedia',
    'forceFilter',
  ];

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
    if (nextProps.expanded !== prevState.expandedProp) {
      update.expandedProp = nextProps.expanded;
      updated = true;
    }
    if (nextProps.status?.get('hidden') !== prevState.statusPropHidden) {
      update.statusPropHidden = nextProps.status?.get('hidden');
      updated = true;
    }

    // Update state based on new props
    if (!nextProps.settings.getIn(['collapsed', 'enabled'])) {
      if (prevState.isCollapsed) {
        update.isCollapsed = false;
        updated = true;
      }
    }

    // Handle uncollapsing toots when the shared CW state is expanded
    if (nextProps.settings.getIn(['content_warnings', 'shared_state']) &&
      nextProps.status?.get('spoiler_text')?.length && nextProps.status?.get('hidden') === false &&
      prevState.statusPropHidden !== false && prevState.isCollapsed
    ) {
      update.isCollapsed = false;
      updated = true;
    }

    // The “expanded” prop is used to one-off change the local state.
    // It's used in the thread view when unfolding/re-folding all CWs at once.
    if (nextProps.expanded !== prevState.expandedProp &&
      nextProps.expanded !== undefined
    ) {
      update.isExpanded = nextProps.expanded;
      if (nextProps.expanded) update.isCollapsed = false;
      updated = true;
    }

    if (prevState.isExpanded === undefined && update.isExpanded === undefined) {
      update.isExpanded = autoUnfoldCW(nextProps.settings, nextProps.status);
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
  //      over the user set value (default 400 without media, or 610px with).
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

    // Don't autocollapse if CW state is shared and status is explicitly revealed,
    // as it could cause surprising changes when receiving notifications
    if (settings.getIn(['content_warnings', 'shared_state']) && status.get('spoiler_text').length && !status.get('hidden')) return;

    let autoCollapseHeight = parseInt(autoCollapseSettings.get('height'));
    if (status.get('media_attachments').size && !muted) {
      autoCollapseHeight += 210;
    }

    if (collapse ||
      autoCollapseSettings.get('all') ||
      (autoCollapseSettings.get('notifications') && muted) ||
      (autoCollapseSettings.get('lengthy') && node.clientHeight > autoCollapseHeight) ||
      (autoCollapseSettings.get('reblogs') && prepend === 'reblogged_by') ||
      (autoCollapseSettings.get('replies') && status.get('in_reply_to_id', null) !== null) ||
      (autoCollapseSettings.get('media') && !(status.get('spoiler_text').length) && status.get('media_attachments').size > 0)
    ) {
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
  getSnapshotBeforeUpdate() {
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

  componentDidUpdate(prevProps, prevState, snapshot) {
    if (snapshot !== null && this.props.updateScrollBottom && this.node.offsetTop < snapshot.top) {
      this.props.updateScrollBottom(snapshot.height - snapshot.top);
    }

    // This will potentially cause a wasteful redraw, but in most cases `Status` components are used
    // with a `key` directly depending on their `id`, preventing re-use of the component across
    // different IDs.
    // But just in case this does change, reset the state on status change.

    if (this.props.status?.get('id') !== prevProps.status?.get('id')) {
      this.setState({
        showMedia: defaultMediaVisibility(this.props.status, this.props.settings) && !(this.context?.hideMediaByDefault),
        forceFilter: undefined,
      });
    }
  }

  componentWillUnmount() {
    if (this.node && this.props.getScrollPosition) {
      const position = this.props.getScrollPosition();
      if (position !== null && this.node.offsetTop < position.top) {
        requestAnimationFrame(() => {
          this.props.updateScrollBottom(position.height - position.top);
        });
      }
    }
  }

  //  `setCollapsed()` sets the value of `isCollapsed` in our state, that is,
  //  whether the toot is collapsed or not.

  //  `setCollapsed()` automatically checks for us whether toot collapsing
  //  is enabled, so we don't have to.
  setCollapsed = (value) => {
    if (this.props.settings.getIn(['collapsed', 'enabled'])) {
      if (value) {
        this.setExpansion(false);
      }
      this.setState({ isCollapsed: value });
    } else {
      this.setState({ isCollapsed: false });
    }
  };

  setExpansion = (value) => {
    if (this.props.settings.getIn(['content_warnings', 'shared_state']) && this.props.status.get('hidden') === value) {
      this.props.onToggleHidden(this.props.status);
    }

    this.setState({ isExpanded: value });
    if (value) {
      this.setCollapsed(false);
    }
  };

  //  `parseClick()` takes a click event and responds appropriately.
  //  If our status is collapsed, then clicking on it should uncollapse it.
  //  If `Shift` is held, then clicking on it should collapse it.
  //  Otherwise, we open the url handed to us in `destination`, if
  //  applicable.
  parseClick = (e, destination) => {
    const { status, history } = this.props;
    const { isCollapsed } = this.state;
    if (!history) return;

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
          destination = `/@${
            status.getIn(['reblog', 'account', 'acct'], status.getIn(['account', 'acct']))
          }/${
            status.getIn(['reblog', 'id'], status.get('id'))
          }`;
        }
        history.push(destination);
      }
      e.preventDefault();
    }
  };

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  };

  handleExpandedToggle = () => {
    if (this.props.settings.getIn(['content_warnings', 'shared_state'])) {
      this.props.onToggleHidden(this.props.status);
    } else if (this.props.status.get('spoiler_text')) {
      this.setExpansion(!this.state.isExpanded);
    }
  };

  handleOpenVideo = (options) => {
    const { status } = this.props;
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), lang, options);
  };

  handleOpenMedia = (media, index) => {
    const { status } = this.props;
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenMedia(status.get('id'), media, index, lang);
  };

  handleHotkeyOpenMedia = e => {
    const { status, onOpenMedia, onOpenVideo } = this.props;
    const statusId = status.get('id');

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      const lang = status.getIn(['translation', 'language']) || status.get('language');
      if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        onOpenVideo(statusId, status.getIn(['media_attachments', 0]), lang, { startTime: 0 });
      } else {
        onOpenMedia(statusId, status.get('media_attachments'), 0, lang);
      }
    }
  };

  handleDeployPictureInPicture = (type, mediaProps) => {
    const { deployPictureInPicture, status } = this.props;

    deployPictureInPicture(status, type, mediaProps);
  };

  handleHotkeyReply = e => {
    e.preventDefault();
    this.props.onReply(this.props.status, this.props.history);
  };

  handleHotkeyFavourite = (e) => {
    this.props.onFavourite(this.props.status, e);
  };

  handleHotkeyBoost = e => {
    this.props.onReblog(this.props.status, e);
  };

  handleHotkeyBookmark = e => {
    this.props.onBookmark(this.props.status, e);
  };

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this.props.status.get('account'), this.props.history);
  };

  handleHotkeyOpen = () => {
    const status = this.props.status;
    this.props.history.push(`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`);
  };

  handleHotkeyOpenProfile = () => {
    this.props.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
  };

  handleHotkeyMoveUp = e => {
    this.props.onMoveUp(this.props.containerId || this.props.id, e.target.getAttribute('data-featured'));
  };

  handleHotkeyMoveDown = e => {
    this.props.onMoveDown(this.props.containerId || this.props.id, e.target.getAttribute('data-featured'));
  };

  handleHotkeyCollapse = () => {
    if (!this.props.settings.getIn(['collapsed', 'enabled']))
      return;

    this.setCollapsed(!this.state.isCollapsed);
  };

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  };

  handleUnfilterClick = e => {
    this.setState({ forceFilter: false });
    e.preventDefault();
  };

  handleFilterClick = () => {
    this.setState({ forceFilter: true });
  };

  handleRef = c => {
    this.node = c;
  };

  handleTranslate = () => {
    this.props.onTranslate(this.props.status);
  };

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
      parseClick,
      setCollapsed,
    } = this;
    const {
      intl,
      status,
      account,
      settings,
      collapsed,
      muted,
      intersectionObserverWrapper,
      onOpenVideo,
      onOpenMedia,
      notification,
      hidden,
      unread,
      featured,
      pictureInPicture,
      previousId,
      nextInReplyToId,
      rootId,
      history,
      ...other
    } = this.props;
    const { isCollapsed } = this.state;
    let background = null;
    let attachments = null;

    //  Depending on user settings, some media are considered as parts of the
    //  contents (affected by CW) while other will be displayed outside of the
    //  CW.
    let contentMedia = [];
    let contentMediaIcons = [];
    let extraMedia = [];
    let extraMediaIcons = [];
    let media = contentMedia;
    let mediaIcons = contentMediaIcons;

    if (settings.getIn(['content_warnings', 'media_outside'])) {
      media = extraMedia;
      mediaIcons = extraMediaIcons;
    }

    if (status === null) {
      return null;
    }

    const isExpanded = settings.getIn(['content_warnings', 'shared_state']) ? !status.get('hidden') : this.state.isExpanded;

    const handlers = {
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleHotkeyMention,
      open: this.handleHotkeyOpen,
      openProfile: this.handleHotkeyOpenProfile,
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      toggleHidden: this.handleExpandedToggle,
      bookmark: this.handleHotkeyBookmark,
      toggleCollapse: this.handleHotkeyCollapse,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
    };

    let prepend, rebloggedByText;

    if (hidden) {
      return (
        <HotKeys handlers={handlers}>
          <div ref={this.handleRef} className='status focusable' tabIndex={0}>
            <span>{status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}</span>
            <span>{status.get('content')}</span>
          </div>
        </HotKeys>
      );
    }

    const connectUp = previousId && previousId === status.get('in_reply_to_id');
    const connectToRoot = rootId && rootId === status.get('in_reply_to_id');
    const connectReply = nextInReplyToId && nextInReplyToId === status.get('id');
    const matchedFilters = status.get('matched_filters');

    if (this.state.forceFilter === undefined ? matchedFilters : this.state.forceFilter) {
      const minHandlers = this.props.muted ? {} : {
        moveUp: this.handleHotkeyMoveUp,
        moveDown: this.handleHotkeyMoveDown,
      };

      return (
        <HotKeys handlers={minHandlers}>
          <div className='status__wrapper status__wrapper--filtered focusable' tabIndex={0} ref={this.handleRef}>
            <FormattedMessage id='status.filtered' defaultMessage='Filtered' />: {matchedFilters.join(', ')}.
            {' '}
            <button className='status__wrapper--filtered__button' onClick={this.handleUnfilterClick}>
              <FormattedMessage id='status.show_filter_reason' defaultMessage='Show anyway' />
            </button>
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

    if (pictureInPicture.get('inUse')) {
      media.push(<PictureInPicturePlaceholder />);
      mediaIcons.push('video-camera');
    } else if (attachments.size > 0) {
      const language = status.getIn(['translation', 'language']) || status.get('language');

      if (muted || attachments.some(item => item.get('type') === 'unknown')) {
        media.push(
          <AttachmentList
            compact
            media={status.get('media_attachments')}
          />,
        );
      } else if (attachments.getIn([0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media.push(
          <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
            {Component => (
              <Component
                src={attachment.get('url')}
                alt={description}
                lang={language}
                poster={attachment.get('preview_url') || status.getIn(['account', 'avatar_static'])}
                backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
                foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
                accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
                duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
                width={this.props.cachedMediaWidth}
                height={110}
                cacheWidth={this.props.cacheMediaWidth}
                deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                sensitive={status.get('sensitive')}
                blurhash={attachment.get('blurhash')}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
              />
            )}
          </Bundle>,
        );
        mediaIcons.push('music');
      } else if (attachments.getIn([0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media.push(
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (<Component
              preview={attachment.get('preview_url')}
              frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
              blurhash={attachment.get('blurhash')}
              src={attachment.get('url')}
              alt={description}
              lang={language}
              inline
              sensitive={status.get('sensitive')}
              letterbox={settings.getIn(['media', 'letterbox'])}
              fullwidth={!rootId && settings.getIn(['media', 'fullwidth'])}
              preventPlayback={isCollapsed || !isExpanded}
              onOpenVideo={this.handleOpenVideo}
              deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
              visible={this.state.showMedia}
              onToggleVisibility={this.handleToggleMediaVisibility}
            />)}
          </Bundle>,
        );
        mediaIcons.push('video-camera');
      } else {  //  Media type is 'image' or 'gifv'
        media.push(
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery}>
            {Component => (
              <Component
                media={attachments}
                lang={language}
                sensitive={status.get('sensitive')}
                letterbox={settings.getIn(['media', 'letterbox'])}
                fullwidth={!rootId && settings.getIn(['media', 'fullwidth'])}
                hidden={isCollapsed || !isExpanded}
                onOpenMedia={this.handleOpenMedia}
                cacheWidth={this.props.cacheMediaWidth}
                defaultWidth={this.props.cachedMediaWidth}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
              />
            )}
          </Bundle>,
        );
        mediaIcons.push('picture-o');
      }

      if (!status.get('sensitive') && !(status.get('spoiler_text').length > 0) && settings.getIn(['collapsed', 'backgrounds', 'preview_images'])) {
        background = attachments.getIn([0, 'preview_url']);
      }
    } else if (status.get('card') && settings.get('inline_preview_cards') && !this.props.muted) {
      media.push(
        <Card
          onOpenMedia={this.handleOpenMedia}
          card={status.get('card')}
          sensitive={status.get('sensitive')}
        />,
      );
      mediaIcons.push('link');
    }

    if (status.get('poll')) {
      const language = status.getIn(['translation', 'language']) || status.get('language');
      contentMedia.push(<PollContainer pollId={status.get('poll')} lang={language} />);
      contentMediaIcons.push('tasks');
    }

    //  Here we prepare extra data-* attributes for CSS selectors.
    //  Users can use those for theming, hiding avatars etc via UserStyle
    const selectorAttribs = {
      'data-status-by': `@${status.getIn(['account', 'acct'])}`,
    };

    if (this.props.prepend && account) {
      const notifKind = {
        favourite: 'favourited',
        reblog: 'boosted',
        reblogged_by: 'boosted',
        status: 'posted',
      }[this.props.prepend];

      selectorAttribs[`data-${notifKind}-by`] = `@${account.get('acct')}`;

      prepend = (
        <StatusPrepend
          type={this.props.prepend}
          account={account}
          parseClick={parseClick}
          notificationId={this.props.notificationId}
        >
          {muted && settings.getIn(['collapsed', 'enabled']) && (
            <div className='notification__message-collapse-button'>
              <CollapseButton collapsed={isCollapsed} setCollapsed={setCollapsed} />
            </div>
          )}
        </StatusPrepend>
      );
    }

    if (this.props.prepend === 'reblog') {
      rebloggedByText = intl.formatMessage({ id: 'status.reblogged_by', defaultMessage: '{name} boosted' }, { name: account.get('acct') });
    }

    const {statusContentProps, hashtagBar} = getHashtagBarForStatus(status);
    contentMedia.push(hashtagBar);

    return (
      <HotKeys handlers={handlers}>
        <div
          className={classNames('status__wrapper', 'focusable', `status__wrapper-${status.get('visibility')}`, { 'status__wrapper-reply': !!status.get('in_reply_to_id'), unread, collapsed: isCollapsed })}
          {...selectorAttribs}
          tabIndex={0}
          data-featured={featured ? 'true' : null}
          aria-label={textForScreenReader(intl, status, rebloggedByText, !status.get('hidden'))}
          ref={this.handleRef}
          data-nosnippet={status.getIn(['account', 'noindex'], true) || undefined}
        >
          {prepend}

          <div
            className={classNames('status', `status-${status.get('visibility')}`, { 'status-reply': !!status.get('in_reply_to_id'), 'status--in-thread': !!rootId, 'status--first-in-thread': previousId && (!connectUp || connectToRoot), muted: this.props.muted, 'has-background': isCollapsed && background, collapsed: isCollapsed })}
            data-id={status.get('id')}
            style={isCollapsed && background ? { backgroundImage: `url(${background})` } : null}
          >
            {(connectReply || connectUp || connectToRoot) && <div className={classNames('status__line', { 'status__line--full': connectReply, 'status__line--first': !status.get('in_reply_to_id') && !connectToRoot })} />}

            {(!muted || !isCollapsed) && (
              <header className='status__info'>
                <StatusHeader
                  status={status}
                  friend={account}
                  collapsed={isCollapsed}
                  parseClick={parseClick}
                />
                <StatusIcons
                  status={status}
                  mediaIcons={contentMediaIcons.concat(extraMediaIcons)}
                  collapsible={!muted && settings.getIn(['collapsed', 'enabled'])}
                  collapsed={isCollapsed}
                  setCollapsed={setCollapsed}
                  settings={settings.get('status_icons')}
                />
              </header>
            )}
            <StatusContent
              status={status}
              media={contentMedia}
              extraMedia={extraMedia}
              mediaIcons={contentMediaIcons}
              expanded={isExpanded}
              onExpandedToggle={this.handleExpandedToggle}
              onTranslate={this.handleTranslate}
              parseClick={parseClick}
              disabled={!history}
              tagLinks={settings.get('tag_misleading_links')}
              rewriteMentions={settings.get('rewrite_mentions')}
              {...statusContentProps}
            />

            {(!isCollapsed || !(muted || !settings.getIn(['collapsed', 'show_action_bar']))) && (
              <StatusActionBar
                status={status}
                account={status.get('account')}
                showReplyCount={settings.get('show_reply_count')}
                onFilter={matchedFilters ? this.handleFilterClick : null}
                {...other}
              />
            )}
            {notification && (
              <NotificationOverlayContainer
                notification={notification}
              />
            )}
          </div>
        </div>
      </HotKeys>
    );
  }

}

export default withOptionalRouter(injectIntl(Status));
