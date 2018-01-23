import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import StatusPrepend from './status_prepend';
import StatusHeader from './status_header';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, Video } from 'flavours/glitch/util/async-components';
import { HotKeys } from 'react-hotkeys';
import NotificationOverlayContainer from 'flavours/glitch/features/notifications/containers/overlay_container';
import classNames from 'classnames';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

export default class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    containerId: PropTypes.string,
    id: PropTypes.string,
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.map,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onPin: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    muted: PropTypes.bool,
    collapse: PropTypes.bool,
    hidden: PropTypes.bool,
    prepend: PropTypes.string,
    withDismiss: PropTypes.bool,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
  };

  state = {
    isExpanded: null,
  }

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'settings',
    'prepend',
    'boostModal',
    'favouriteModal',
    'muted',
    'collapse',
    'notification',
    'hidden',
  ]

  updateOnStates = [
    'isExpanded',
  ]

  //  If our settings have changed to disable collapsed statuses, then we
  //  need to make sure that we uncollapse every one. We do that by watching
  //  for changes to `settings.collapsed.enabled` in
  //  `componentWillReceiveProps()`.

  //  We also need to watch for changes on the `collapse` prop---if this
  //  changes to anything other than `undefined`, then we need to collapse or
  //  uncollapse our status accordingly.
  componentWillReceiveProps (nextProps) {
    if (!nextProps.settings.getIn(['collapsed', 'enabled'])) {
      if (this.state.isExpanded === false) {
        this.setExpansion(null);
      }
    } else if (
      nextProps.collapse !== this.props.collapse &&
      nextProps.collapse !== undefined
    ) this.setExpansion(nextProps.collapse ? false : null);
  }

  //  When mounting, we just check to see if our status should be collapsed,
  //  and collapse it if so. We don't need to worry about whether collapsing
  //  is enabled here, because `setExpansion()` already takes that into
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
    }()) this.setExpansion(false);
  }

  //  `setExpansion()` sets the value of `isExpanded` in our state. It takes
  //  one argument, `value`, which gives the desired value for `isExpanded`.
  //  The default for this argument is `null`.

  //  `setExpansion()` automatically checks for us whether toot collapsing
  //  is enabled, so we don't have to.
  setExpansion = (value) => {
    switch (true) {
    case value === undefined || value === null:
      this.setState({ isExpanded: null });
      break;
    case !value && this.props.settings.getIn(['collapsed', 'enabled']):
      this.setState({ isExpanded: false });
      break;
    case !!value:
      this.setState({ isExpanded: true });
      break;
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
    const { isExpanded } = this.state;
    if (!router) return;
    if (destination === undefined) {
      destination = `/statuses/${
        status.getIn(['reblog', 'id'], status.get('id'))
      }`;
    }
    if (e.button === 0) {
      if (isExpanded === false) this.setExpansion(null);
      else if (e.shiftKey) {
        this.setExpansion(false);
        document.getSelection().removeAllRanges();
      } else router.history.push(destination);
      e.preventDefault();
    }
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0) {
      const id = e.currentTarget.getAttribute('data-id');
      e.preventDefault();
      this.context.router.history.push(`/accounts/${id}`);
    }
  }

  handleExpandedToggle = () => {
    if (this.props.status.get('spoiler_text')) {
      this.setExpansion(this.state.isExpanded ? null : true);
    }
  };

  handleOpenVideo = startTime => {
    this.props.onOpenVideo(this.props.status.getIn(['media_attachments', 0]), startTime);
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

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this.props.status.get('account'), this.context.router.history);
  }

  handleHotkeyOpen = () => {
    this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
  }

  handleHotkeyOpenProfile = () => {
    this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
  }

  handleHotkeyMoveUp = () => {
    this.props.onMoveUp(this.props.containerId || this.props.id);
  }

  handleHotkeyMoveDown = () => {
    this.props.onMoveDown(this.props.containerId || this.props.id);
  }

  handleRef = c => {
    this.node = c;
  }

  renderLoadingMediaGallery () {
    return <div className='media_gallery' style={{ height: '110px' }} />;
  }

  renderLoadingVideoPlayer () {
    return <div className='media-spoiler-video' style={{ height: '110px' }} />;
  }

  render () {
    const {
      handleRef,
      parseClick,
      setExpansion,
    } = this;
    const { router } = this.context;
    const {
      status,
      account,
      settings,
      collapsed,
      muted,
      prepend,
      intersectionObserverWrapper,
      onOpenVideo,
      onOpenMedia,
      notification,
      hidden,
      ...other
    } = this.props;
    const { isExpanded } = this.state;
    let background = null;
    let attachments = null;
    let media = null;
    let mediaIcon = null;

    if (status === null) {
      return null;
    }

    if (hidden) {
      return (
        <div
          ref={this.handleRef}
          data-id={status.get('id')}
          style={{
            height: `${this.height}px`,
            opacity: 0,
            overflow: 'hidden',
          }}
        >
          {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
          {' '}
          {status.get('content')}
        </div>
      );
    }

    //  If user backgrounds for collapsed statuses are enabled, then we
    //  initialize our background accordingly. This will only be rendered if
    //  the status is collapsed.
    if (settings.getIn(['collapsed', 'backgrounds', 'user_backgrounds'])) {
      background = status.getIn(['account', 'header']);
    }

    //  This handles our media attachments. Note that we don't show media on
    //  muted (notification) statuses. If the media type is unknown, then we
    //  simply ignore it.

    //  After we have generated our appropriate media element and stored it in
    //  `media`, we snatch the thumbnail to use as our `background` if media
    //  backgrounds for collapsed statuses are enabled.
    attachments = status.get('media_attachments');
    if (attachments.size > 0 && !muted) {
      if (attachments.some(item => item.get('type') === 'unknown')) {  //  Media type is 'unknown'
        /*  Do nothing  */
      } else if (attachments.getIn([0, 'type']) === 'video') {  //  Media type is 'video'
        const video = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (<Component
              preview={video.get('preview_url')}
              src={video.get('url')}
              sensitive={status.get('sensitive')}
              letterbox={settings.getIn(['media', 'letterbox'])}
              fullwidth={settings.getIn(['media', 'fullwidth'])}
              onOpenVideo={this.handleOpenVideo}
            />)}
          </Bundle>
        );
        mediaIcon = 'video-camera';
      } else {  //  Media type is 'image' or 'gifv'
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => (
              <Component
                media={attachments}
                sensitive={status.get('sensitive')}
                letterbox={settings.getIn(['media', 'letterbox'])}
                fullwidth={settings.getIn(['media', 'fullwidth'])}
                onOpenMedia={this.props.onOpenMedia}
              />
            )}
          </Bundle>
        );
        mediaIcon = 'picture-o';
      }

      if (!status.get('sensitive') && !(status.get('spoiler_text').length > 0) && settings.getIn(['collapsed', 'backgrounds', 'preview_images'])) {
        background = attachments.getIn([0, 'preview_url']);
      }
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
      }[prepend];

      selectorAttribs[`data-${notifKind}-by`] = `@${account.get('acct')}`;
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
    };

    const computedClass = classNames('status', `status-${status.get('visibility')}`, {
      collapsed: isExpanded === false,
      'has-background': isExpanded === false && background,
      muted,
    }, 'focusable');

    return (
      <HotKeys handlers={handlers}>
        <div
          className={computedClass}
          style={isExpanded === false && background ? { backgroundImage: `url(${background})` } : null}
          {...selectorAttribs}
          ref={handleRef}
          tabIndex='0'
        >
          {prepend && account ? (
            <StatusPrepend
              type={prepend}
              account={account}
              parseClick={parseClick}
              notificationId={this.props.notificationId}
            />
          ) : null}
          <StatusHeader
            status={status}
            friend={account}
            mediaIcon={mediaIcon}
            collapsible={settings.getIn(['collapsed', 'enabled'])}
            collapsed={isExpanded === false}
            parseClick={parseClick}
            setExpansion={setExpansion}
          />
          <StatusContent
            status={status}
            media={media}
            mediaIcon={mediaIcon}
            expanded={isExpanded}
            setExpansion={setExpansion}
            parseClick={parseClick}
            disabled={!router}
          />
          {isExpanded !== false ? (
            <StatusActionBar
              {...other}
              status={status}
              account={status.get('account')}
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
