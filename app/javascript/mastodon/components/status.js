import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import AvatarComposite from './avatar_composite';
import RelativeTimestamp from './relative_timestamp';
import DisplayName from './display_name';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import AttachmentList from './attachment_list';
import Card from '../features/status/components/card';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, Video, Audio } from '../features/ui/util/async-components';
import { HotKeys } from 'react-hotkeys';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import { displayMedia } from '../initial_state';
import PictureInPicturePlaceholder from 'mastodon/components/picture_in_picture_placeholder';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

const mapStateToProps = (state, props) => {
  let status = props.status;

  if (status === null) {
    return null;
  }

  if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
    status = status.get('reblog');
  }

  if (status.get('quote', null) === null) {
    return {
      quote_muted: status.get('quote_id', null) ? true : false,
    };
  }
  const id = status.getIn(['quote', 'account', 'id'], null);

  return {
    quote_muted: id !== null && (state.getIn(['relationships', id, 'muting']) || state.getIn(['relationships', id, 'blocking']) || state.getIn(['relationships', id, 'blocked_by']) || state.getIn(['relationships', id, 'domain_blocking'])) || status.getIn(['quote', 'quote_muted']),
  };
};

export const textForScreenReader = (intl, status, rebloggedByText = false) => {
  const displayName = status.getIn(['account', 'display_name']);

  const values = [
    displayName.length === 0 ? status.getIn(['account', 'acct']).split('@')[0] : displayName,
    status.get('spoiler_text') && status.get('hidden') ? status.get('spoiler_text') : status.get('search_index').slice(status.get('spoiler_text').length),
    intl.formatDate(status.get('created_at'), { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }),
    status.getIn(['account', 'acct']),
  ];

  if (rebloggedByText) {
    values.push(rebloggedByText);
  }

  return values.join(', ');
};

export const defaultMediaVisibility = (status) => {
  if (!status) {
    return undefined;
  }

  if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
    status = status.get('reblog');
  }

  return (displayMedia !== 'hide_all' && !status.get('sensitive') || displayMedia === 'show_all');
};

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

export default @connect(mapStateToProps)
@injectIntl
class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.map,
    otherAccounts: ImmutablePropTypes.list,
    quote_muted: PropTypes.bool,
    onClick: PropTypes.func,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onPin: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    onToggleHidden: PropTypes.func,
    onToggleCollapsed: PropTypes.func,
    onQuoteToggleHidden: PropTypes.func,
    muted: PropTypes.bool,
    hidden: PropTypes.bool,
    unread: PropTypes.bool,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
    showThread: PropTypes.bool,
    getScrollPosition: PropTypes.func,
    updateScrollBottom: PropTypes.func,
    cacheMediaWidth: PropTypes.func,
    cachedMediaWidth: PropTypes.number,
    scrollKey: PropTypes.string,
    deployPictureInPicture: PropTypes.func,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
    contextType: PropTypes.string,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'muted',
    'hidden',
    'unread',
    'pictureInPicture',
    'quote_muted',
  ];

  state = {
    showMedia: defaultMediaVisibility(this.props.status),
    showQuoteMedia: defaultMediaVisibility(this.props.status ? this.props.status.get('quote', null) : null),
    statusId: undefined,
  };

  static getDerivedStateFromProps(nextProps, prevState) {
    if (nextProps.status && nextProps.status.get('id') !== prevState.statusId) {
      return {
        showMedia: defaultMediaVisibility(nextProps.status),
        showQuoteMedia: defaultMediaVisibility(nextProps.status.get('quote', null)),
        statusId: nextProps.status.get('id'),
      };
    } else {
      return null;
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  }

  handleToggleQuoteMediaVisibility = () => {
    this.setState({ showQuoteMedia: !this.state.showQuoteMedia });
  }

  handleClick = e => {
    if (e && (e.button !== 0 || e.ctrlKey || e.metaKey)) {
      return;
    }

    if (e) {
      e.preventDefault();
    }

    this.handleHotkeyOpen();
  }

  handleAccountClick = e => {
    if (e && (e.button !== 0 || e.ctrlKey || e.metaKey))  {
      return;
    }

    if (e.button === 0) {
      if (!this.context.router) {
        return;
      }

      const { status } = this.props;
      this.context.router.history.push(`/statuses/${status.getIn(['reblog', 'id'], status.get('id'))}`);
    }
  }

  handleQuoteClick = () => {
    if (!this.context.router) {
      return;
    }

    const { status } = this.props;
    this.context.router.history.push(`/statuses/${status.getIn(['reblog', 'quote', 'id'], status.getIn(['quote', 'id']))}`);
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      const id = e.currentTarget.getAttribute('data-id');
      e.preventDefault();
    }

    this.handleHotkeyOpenProfile();
  }

  handleExpandedToggle = () => {
    this.props.onToggleHidden(this._properStatus());
  }

  handleCollapsedToggle = isCollapsed => {
    this.props.onToggleCollapsed(this._properStatus(), isCollapsed);
  }

  handleExpandedQuoteToggle = () => {
    this.props.onQuoteToggleHidden(this._properStatus());
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

  handleOpenVideo = (options) => {
    const status = this._properStatus();
    this.props.onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), options);
  }

  handleOpenVideoQuote = (options) => {
    const status = this._properQuoteStatus();
    this.props.onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), options);
  }

  handleOpenMedia = (media, index) => {
    this.props.onOpenMedia(this._properStatus().get('id'), media, index);
  }

  handleOpenMediaQuote = (media, index) => {
    this.props.onOpenMedia(this._properQuoteStatus().get('id'), media, index);
  }

  handleHotkeyOpenMedia = e => {
    const { onOpenMedia, onOpenVideo } = this.props;
    const status = this._properStatus();

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), { startTime: 0 });
      } else {
        onOpenMedia(status.get('id'), status.get('media_attachments'), 0);
      }
    }
  }

  handleDeployPictureInPicture = (type, mediaProps) => {
    const { deployPictureInPicture } = this.props;
    const status = this._properStatus();

    deployPictureInPicture(status, type, mediaProps);
  }

  handleHotkeyReply = e => {
    e.preventDefault();
    this.props.onReply(this._properStatus(), this.context.router.history);
  }

  handleHotkeyFavourite = () => {
    this.props.onFavourite(this._properStatus());
  }

  handleHotkeyBoost = e => {
    this.props.onReblog(this._properStatus(), e);
  }

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this._properStatus().get('account'), this.context.router.history);
  }

  handleHotkeyOpen = () => {
    if (this.props.onClick) {
      this.props.onClick();
      return;
    }

    const { router } = this.context;
    const status = this._properStatus();

    if (!router) {
      return;
    }

    router.history.push(`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`);
  }

  handleHotkeyOpenProfile = () => {
    const { router } = this.context;
    const status = this._properStatus();

    if (!router) {
      return;
    }

    router.history.push(`/@${status.getIn(['account', 'acct'])}`);
  }

  handleHotkeyMoveUp = e => {
    this.props.onMoveUp(this.props.status.get('id'), e.target.getAttribute('data-featured'));
  }

  handleHotkeyMoveDown = e => {
    this.props.onMoveDown(this.props.status.get('id'), e.target.getAttribute('data-featured'));
  }

  handleHotkeyToggleHidden = () => {
    this.props.onToggleHidden(this._properStatus());
  }

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  }

  _properStatus () {
    const { status } = this.props;

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      return status.get('reblog');
    } else {
      return status;
    }
  }

  _properQuoteStatus () {
    const status = this._properStatus();

    if (status.get('quote', null) !== null && typeof status.get('quote') === 'object') {
      return status.get('quote');
    } else {
      return status;
    }
  }

  handleRef = c => {
    this.node = c;
  }

  render () {
    let media = null;
    let statusAvatar, prepend, rebloggedByText;

    const { intl, hidden, featured, otherAccounts, unread, showThread, scrollKey, pictureInPicture, contextType, quote_muted } = this.props;

    let { status, account, ...other } = this.props;

    if (status === null) {
      return null;
    }

    const handlers = this.props.muted ? {} : {
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleHotkeyMention,
      open: this.handleHotkeyOpen,
      openProfile: this.handleHotkeyOpenProfile,
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      toggleHidden: this.handleHotkeyToggleHidden,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
    };

    if (hidden) {
      return (
        <HotKeys handlers={handlers}>
          <div ref={this.handleRef} className={classNames('status__wrapper', { focusable: !this.props.muted })} tabIndex='0'>
            <span>{status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}</span>
            <span>{status.get('content')}</span>
          </div>
        </HotKeys>
      );
    }

    if (status.get('filtered') || status.getIn(['reblog', 'filtered'])) {
      const minHandlers = this.props.muted ? {} : {
        moveUp: this.handleHotkeyMoveUp,
        moveDown: this.handleHotkeyMoveDown,
      };

      return (
        <HotKeys handlers={minHandlers}>
          <div className='status__wrapper status__wrapper--filtered focusable' tabIndex='0' ref={this.handleRef}>
            <FormattedMessage id='status.filtered' defaultMessage='Filtered' />
          </div>
        </HotKeys>
      );
    }

    if (featured) {
      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='thumb-tack' className='status__prepend-icon' fixedWidth /></div>
          <FormattedMessage id='status.pinned' defaultMessage='Pinned toot' />
        </div>
      );
    } else if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      const display_name_html = { __html: status.getIn(['account', 'display_name_html']) };

      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='retweet' className='status__prepend-icon' fixedWidth /></div>
          <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name muted'><bdi><strong dangerouslySetInnerHTML={display_name_html} /></bdi></a> }} />
        </div>
      );

      rebloggedByText = intl.formatMessage({ id: 'status.reblogged_by', defaultMessage: '{name} boosted' }, { name: status.getIn(['account', 'acct']) });

      account = status.get('account');
      status  = status.get('reblog');
    }

    if (status.get('media_attachments').size > 0) {
      if (pictureInPicture.get('inUse')) {
        media = <PictureInPicturePlaceholder width={this.props.cachedMediaWidth} />;
      } else if (this.props.muted) {
        media = (
          <AttachmentList
            compact
            media={status.get('media_attachments')}
          />
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
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
                deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
              />
            )}
          </Bundle>
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={attachment.get('preview_url')}
                frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
                blurhash={attachment.get('blurhash')}
                src={attachment.get('url')}
                alt={attachment.get('description')}
                width={this.props.cachedMediaWidth}
                height={110}
                inline
                sensitive={status.get('sensitive')}
                onOpenVideo={this.handleOpenVideo}
                cacheWidth={this.props.cacheMediaWidth}
                deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
              />
            )}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery}>
            {Component => (
              <Component
                media={status.get('media_attachments')}
                sensitive={status.get('sensitive')}
                height={110}
                onOpenMedia={this.handleOpenMedia}
                cacheWidth={this.props.cacheMediaWidth}
                defaultWidth={this.props.cachedMediaWidth}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
              />
            )}
          </Bundle>
        );
      }
    } else if (status.get('spoiler_text').length === 0 && status.get('card')) {
      media = (
        <Card
          onOpenMedia={this.handleOpenMedia}
          card={status.get('card')}
          compact
          cacheWidth={this.props.cacheMediaWidth}
          defaultWidth={this.props.cachedMediaWidth}
          sensitive={status.get('sensitive')}
        />
      );
    }

    if (otherAccounts && otherAccounts.size > 0) {
      statusAvatar = <AvatarComposite accounts={otherAccounts} size={48} />;
    } else if (account === undefined || account === null) {
      statusAvatar = <Avatar account={status.get('account')} size={48} />;
    } else {
      statusAvatar = <AvatarOverlay account={status.get('account')} friend={account} />;
    }

    const visibilityIconInfo = {
      'public': { icon: 'globe', text: intl.formatMessage(messages.public_short) },
      'unlisted': { icon: 'unlock', text: intl.formatMessage(messages.unlisted_short) },
      'private': { icon: 'lock', text: intl.formatMessage(messages.private_short) },
      'direct': { icon: 'envelope', text: intl.formatMessage(messages.direct_short) },
    };

    const visibilityIcon = visibilityIconInfo[status.get('visibility')];

    let quote = null;
    if (status.get('quote', null) !== null && typeof status.get('quote') === 'object') {
      let quote_status = status.get('quote');

      let quote_media = null;
      if (quote_status.get('media_attachments').size > 0) {
        if (pictureInPicture.get('inUse')) {
          quote_media = <PictureInPicturePlaceholder width={this.props.cachedMediaWidth} />;
        } else if (this.props.muted) {
          quote_media = (
            <AttachmentList
              compact
              media={quote_status.get('media_attachments')}
            />
          );
        } else if (quote_status.getIn(['media_attachments', 0, 'type']) === 'audio') {
          const attachment = quote_status.getIn(['media_attachments', 0]);

          quote_media = (
            <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
              {Component => (
                <Component
                  src={attachment.get('url')}
                  alt={attachment.get('description')}
                  poster={attachment.get('preview_url') || quote_status.getIn(['account', 'avatar_static'])}
                  backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
                  foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
                  accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
                  duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
                  width={this.props.cachedMediaWidth}
                  height={70}
                  cacheWidth={this.props.cacheMediaWidth}
                  deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                  />
              )}
            </Bundle>
          );
        } else if (quote_status.getIn(['media_attachments', 0, 'type']) === 'video') {
          const attachment = quote_status.getIn(['media_attachments', 0]);

          quote_media = (
            <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
              {Component => (
                <Component
                  preview={attachment.get('preview_url')}
                  frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
                  blurhash={attachment.get('blurhash')}
                  src={attachment.get('url')}
                  alt={attachment.get('description')}
                  width={this.props.cachedMediaWidth}
                  height={110}
                  inline
                  sensitive={quote_status.get('sensitive')}
                  onOpenVideo={this.handleOpenVideoQuote}
                  cacheWidth={this.props.cacheMediaWidth}
                  deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                  visible={this.state.showQuoteMedia}
                  onToggleVisibility={this.handleToggleQuoteMediaVisibility}
                  quote
                />
              )}
            </Bundle>
          );
        } else {
          quote_media = (
            <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery}>
              {Component => (
                <Component
                  media={quote_status.get('media_attachments')}
                  sensitive={quote_status.get('sensitive')}
                  height={110}
                  onOpenMedia={this.handleOpenMediaQuote}
                  cacheWidth={this.props.cacheMediaWidth}
                  defaultWidth={this.props.cachedMediaWidth}
                  visible={this.state.showQuoteMedia}
                  onToggleVisibility={this.handleToggleQuoteMediaVisibility}
                  quote
                />
              )}
            </Bundle>
          );
        }
      }

      if (quote_muted) {
        quote = (
          <div className={classNames('quote-status', `status-${quote_status.get('visibility')}`, { muted: this.props.muted })} data-id={quote_status.get('id')}>
            <div className={classNames('status__content muted-quote', { 'status__content--with-action': this.context.router })}>
              <FormattedMessage id='status.muted_quote' defaultMessage='Muted quote' />
            </div>
          </div>
        );
      } else if (quote_status.get('visibility') === 'unlisted' && !!contextType && ['public', 'community', 'hashtag'].includes(contextType.split(':', 2)[0])) {
        quote = (
          <div className={classNames('quote-status', `status-${quote_status.get('visibility')}`, { muted: this.props.muted })} data-id={quote_status.get('id')}>
            <div className={classNames('status__content unlisted-quote', { 'status__content--with-action': this.context.router })}>
              <button onClick={this.handleQuoteClick}>
                <FormattedMessage id='status.unlisted_quote' defaultMessage='Unlisted quote' />
              </button>
            </div>
          </div>
        );
      } else {
        quote = (
          <div className={classNames('quote-status', `status-${quote_status.get('visibility')}`, { muted: this.props.muted })} data-id={quote_status.get('id')}>
            <div className='status__info'>
              <a onClick={this.handleAccountClick} target='_blank' data-id={quote_status.getIn(['account', 'id'])} href={quote_status.getIn(['account', 'url'])} title={quote_status.getIn(['account', 'acct'])} className='status__display-name'>
                <div className='status__avatar'><Avatar account={quote_status.get('account')} size={18} /></div>
                <DisplayName account={quote_status.get('account')} />
              </a>
            </div>
            <StatusContent status={quote_status} onClick={this.handleQuoteClick} expanded={!status.get('quote_hidden')} onExpandedToggle={this.handleExpandedQuoteToggle} quote />
            {quote_media}
          </div>
        );
      }
    } else if (quote_muted) {
      quote = (
        <div className={classNames('quote-status', { muted: this.props.muted })}>
          <div className={classNames('status__content muted-quote', { 'status__content--with-action': this.context.router })}>
            <FormattedMessage id='status.muted_quote' defaultMessage='Muted quote' />
          </div>
        </div>
      );
    }

    return (
      <HotKeys handlers={handlers}>
        <div className={classNames('status__wrapper', `status__wrapper-${status.get('visibility')}`, { 'status__wrapper-reply': !!status.get('in_reply_to_id'), unread, focusable: !this.props.muted })} tabIndex={this.props.muted ? null : 0} data-featured={featured ? 'true' : null} aria-label={textForScreenReader(intl, status, rebloggedByText)} ref={this.handleRef}>
          {prepend}

          <div className={classNames('status', `status-${status.get('visibility')}`, { 'status-reply': !!status.get('in_reply_to_id'), muted: this.props.muted })} data-id={status.get('id')}>
            <div className='status__expand' onClick={this.handleClick} role='presentation' />

            <div className='status__info'>
              <a onClick={this.handleClick} href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener noreferrer'>
                <span className='status__visibility-icon'><Icon id={visibilityIcon.icon} title={visibilityIcon.text} /></span>
                <RelativeTimestamp timestamp={status.get('created_at')} />
              </a>

              <a onClick={this.handleAccountClick} href={status.getIn(['account', 'url'])} title={status.getIn(['account', 'acct'])} className='status__display-name' target='_blank' rel='noopener noreferrer'>
                <div className='status__avatar'>
                  {statusAvatar}
                </div>

                <DisplayName account={status.get('account')} others={otherAccounts} />
              </a>
            </div>

            <StatusContent status={status} onClick={this.handleClick} expanded={!status.get('hidden')} showThread={showThread} onExpandedToggle={this.handleExpandedToggle} collapsable onCollapsedToggle={this.handleCollapsedToggle} />

            {quote}
            {media}

            <StatusActionBar scrollKey={scrollKey} status={status} account={account} {...other} />
          </div>
        </div>
      </HotKeys>
    );
  }

}
