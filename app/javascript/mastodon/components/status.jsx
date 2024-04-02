import PropTypes from 'prop-types';

import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { HotKeys } from 'react-hotkeys';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import PushPinIcon from '@/material-icons/400-24px/push_pin.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import { Icon }  from 'mastodon/components/icon';
import PictureInPicturePlaceholder from 'mastodon/components/picture_in_picture_placeholder';
import { withOptionalRouter, WithOptionalRouterPropTypes } from 'mastodon/utils/react_router';

import Card from '../features/status/components/card';
// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';
import { MediaGallery, Video, Audio } from '../features/ui/util/async-components';
import { SensitiveMediaContext } from '../features/ui/util/sensitive_media_context';
import { displayMedia } from '../initial_state';

import { Avatar } from './avatar';
import { AvatarOverlay } from './avatar_overlay';
import { DisplayName } from './display_name';
import { getHashtagBarForStatus } from './hashtag_bar';
import { RelativeTimestamp } from './relative_timestamp';
import StatusActionBar from './status_action_bar';
import StatusContent from './status_content';
import { VisibilityIcon } from './visibility_icon';

const domParser = new DOMParser();

export const textForScreenReader = (intl, status, rebloggedByText = false) => {
  const displayName = status.getIn(['account', 'display_name']);

  const spoilerText = status.getIn(['translation', 'spoiler_text']) || status.get('spoiler_text');
  const contentHtml = status.getIn(['translation', 'contentHtml']) || status.get('contentHtml');
  const contentText = domParser.parseFromString(contentHtml, 'text/html').documentElement.textContent;

  const values = [
    displayName.length === 0 ? status.getIn(['account', 'acct']).split('@')[0] : displayName,
    spoilerText && status.get('hidden') ? spoilerText : contentText,
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
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Quiet public' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Specific people' },
  edited: { id: 'status.edited', defaultMessage: 'Edited {date}' },
});

class Status extends ImmutablePureComponent {

  static contextType = SensitiveMediaContext;

  static propTypes = {
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.record,
    previousId: PropTypes.string,
    nextInReplyToId: PropTypes.string,
    rootId: PropTypes.string,
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
    onAddFilter: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    onToggleHidden: PropTypes.func,
    onToggleCollapsed: PropTypes.func,
    onTranslate: PropTypes.func,
    onInteractionModal: PropTypes.func,
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
    ...WithOptionalRouterPropTypes,
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
  ];

  state = {
    showMedia: defaultMediaVisibility(this.props.status) && !(this.context?.hideMediaByDefault),
    forceFilter: undefined,
  };

  componentDidUpdate (prevProps) {
    // This will potentially cause a wasteful redraw, but in most cases `Status` components are used
    // with a `key` directly depending on their `id`, preventing re-use of the component across
    // different IDs.
    // But just in case this does change, reset the state on status change.

    if (this.props.status?.get('id') !== prevProps.status?.get('id')) {
      this.setState({
        showMedia: defaultMediaVisibility(this.props.status) && !(this.context?.hideMediaByDefault),
        forceFilter: undefined,
      });
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  };

  handleClick = e => {
    if (e && (e.button !== 0 || e.ctrlKey || e.metaKey)) {
      return;
    }

    if (e) {
      e.preventDefault();
    }

    this.handleHotkeyOpen();
  };

  handlePrependAccountClick = e => {
    this.handleAccountClick(e, false);
  };

  handleAccountClick = (e, proper = true) => {
    if (e && (e.button !== 0 || e.ctrlKey || e.metaKey))  {
      return;
    }

    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }

    this._openProfile(proper);
  };

  handleExpandedToggle = () => {
    this.props.onToggleHidden(this._properStatus());
  };

  handleCollapsedToggle = isCollapsed => {
    this.props.onToggleCollapsed(this._properStatus(), isCollapsed);
  };

  handleTranslate = () => {
    this.props.onTranslate(this._properStatus());
  };

  getAttachmentAspectRatio () {
    const attachments = this._properStatus().get('media_attachments');

    if (attachments.getIn([0, 'type']) === 'video') {
      return `${attachments.getIn([0, 'meta', 'original', 'width'])} / ${attachments.getIn([0, 'meta', 'original', 'height'])}`;
    } else if (attachments.getIn([0, 'type']) === 'audio') {
      return '16 / 9';
    } else {
      return (attachments.size === 1 && attachments.getIn([0, 'meta', 'small', 'aspect'])) ? attachments.getIn([0, 'meta', 'small', 'aspect']) : '3 / 2';
    }
  }

  renderLoadingMediaGallery = () => {
    return (
      <div className='media-gallery' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  renderLoadingVideoPlayer = () => {
    return (
      <div className='video-player' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  renderLoadingAudioPlayer = () => {
    return (
      <div className='audio-player' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  handleOpenVideo = (options) => {
    const status = this._properStatus();
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), lang, options);
  };

  handleOpenMedia = (media, index) => {
    const status = this._properStatus();
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenMedia(status.get('id'), media, index, lang);
  };

  handleHotkeyOpenMedia = e => {
    const { onOpenMedia, onOpenVideo } = this.props;
    const status = this._properStatus();

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      const lang = status.getIn(['translation', 'language']) || status.get('language');
      if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), lang, { startTime: 0 });
      } else {
        onOpenMedia(status.get('id'), status.get('media_attachments'), 0, lang);
      }
    }
  };

  handleDeployPictureInPicture = (type, mediaProps) => {
    const { deployPictureInPicture } = this.props;
    const status = this._properStatus();

    deployPictureInPicture(status, type, mediaProps);
  };

  handleHotkeyReply = e => {
    e.preventDefault();
    this.props.onReply(this._properStatus(), this.props.history);
  };

  handleHotkeyFavourite = () => {
    this.props.onFavourite(this._properStatus());
  };

  handleHotkeyBoost = e => {
    this.props.onReblog(this._properStatus(), e);
  };

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this._properStatus().get('account'), this.props.history);
  };

  handleHotkeyOpen = () => {
    if (this.props.onClick) {
      this.props.onClick();
      return;
    }

    const { history } = this.props;
    const status = this._properStatus();

    if (!history) {
      return;
    }

    history.push(`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`);
  };

  handleHotkeyOpenProfile = () => {
    this._openProfile();
  };

  _openProfile = (proper = true) => {
    const { history } = this.props;
    const status = proper ? this._properStatus() : this.props.status;

    if (!history) {
      return;
    }

    history.push(`/@${status.getIn(['account', 'acct'])}`);
  };

  handleHotkeyMoveUp = e => {
    this.props.onMoveUp(this.props.status.get('id'), e.target.getAttribute('data-featured'));
  };

  handleHotkeyMoveDown = e => {
    this.props.onMoveDown(this.props.status.get('id'), e.target.getAttribute('data-featured'));
  };

  handleHotkeyToggleHidden = () => {
    this.props.onToggleHidden(this._properStatus());
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

  _properStatus () {
    const { status } = this.props;

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      return status.get('reblog');
    } else {
      return status;
    }
  }

  handleRef = c => {
    this.node = c;
  };

  render () {
    const { intl, hidden, featured, unread, showThread, scrollKey, pictureInPicture, previousId, nextInReplyToId, rootId } = this.props;

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

    let media, statusAvatar, prepend, rebloggedByText;

    if (hidden) {
      return (
        <HotKeys handlers={handlers}>
          <div ref={this.handleRef} className={classNames('status__wrapper', { focusable: !this.props.muted })} tabIndex={0}>
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

    if (featured) {
      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='thumb-tack' icon={PushPinIcon} className='status__prepend-icon' /></div>
          <FormattedMessage id='status.pinned' defaultMessage='Pinned post' />
        </div>
      );
    } else if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      const display_name_html = { __html: status.getIn(['account', 'display_name_html']) };

      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='retweet' icon={RepeatIcon} className='status__prepend-icon' /></div>
          <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handlePrependAccountClick} data-id={status.getIn(['account', 'id'])} href={`/@${status.getIn(['account', 'acct'])}`} className='status__display-name muted'><bdi><strong dangerouslySetInnerHTML={display_name_html} /></bdi></a> }} />
        </div>
      );

      rebloggedByText = intl.formatMessage({ id: 'status.reblogged_by', defaultMessage: '{name} boosted' }, { name: status.getIn(['account', 'acct']) });

      account = status.get('account');
      status  = status.get('reblog');
    } else if (status.get('visibility') === 'direct') {
      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='at' icon={AlternateEmailIcon} className='status__prepend-icon' /></div>
          <FormattedMessage id='status.direct_indicator' defaultMessage='Private mention' />
        </div>
      );
    } else if (showThread && status.get('in_reply_to_id') && status.get('in_reply_to_account_id') === status.getIn(['account', 'id'])) {
      const display_name_html = { __html: status.getIn(['account', 'display_name_html']) };

      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><Icon id='reply' icon={ReplyIcon} className='status__prepend-icon' /></div>
          <FormattedMessage id='status.replied_to' defaultMessage='Replied to {name}' values={{ name: <a onClick={this.handlePrependAccountClick} data-id={status.getIn(['account', 'id'])} href={`/@${status.getIn(['account', 'acct'])}`} className='status__display-name muted'><bdi><strong dangerouslySetInnerHTML={display_name_html} /></bdi></a> }} />
        </div>
      );
    }

    if (pictureInPicture.get('inUse')) {
      media = <PictureInPicturePlaceholder aspectRatio={this.getAttachmentAspectRatio()} />;
    } else if (status.get('media_attachments').size > 0) {
      const language = status.getIn(['translation', 'language']) || status.get('language');

      if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media = (
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
          </Bundle>
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={attachment.get('preview_url')}
                frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
                aspectRatio={`${attachment.getIn(['meta', 'original', 'width'])} / ${attachment.getIn(['meta', 'original', 'height'])}`}
                blurhash={attachment.get('blurhash')}
                src={attachment.get('url')}
                alt={description}
                lang={language}
                sensitive={status.get('sensitive')}
                onOpenVideo={this.handleOpenVideo}
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
                lang={language}
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
          sensitive={status.get('sensitive')}
        />
      );
    }

    if (account === undefined || account === null) {
      statusAvatar = <Avatar account={status.get('account')} size={46} />;
    } else {
      statusAvatar = <AvatarOverlay account={status.get('account')} friend={account} />;
    }

    const {statusContentProps, hashtagBar} = getHashtagBarForStatus(status);
    const expanded = !status.get('hidden') || status.get('spoiler_text').length === 0;

    return (
      <HotKeys handlers={handlers}>
        <div className={classNames('status__wrapper', `status__wrapper-${status.get('visibility')}`, { 'status__wrapper-reply': !!status.get('in_reply_to_id'), unread, focusable: !this.props.muted })} tabIndex={this.props.muted ? null : 0} data-featured={featured ? 'true' : null} aria-label={textForScreenReader(intl, status, rebloggedByText)} ref={this.handleRef} data-nosnippet={status.getIn(['account', 'noindex'], true) || undefined}>
          {prepend}

          <div className={classNames('status', `status-${status.get('visibility')}`, { 'status-reply': !!status.get('in_reply_to_id'), 'status--in-thread': !!rootId, 'status--first-in-thread': previousId && (!connectUp || connectToRoot), muted: this.props.muted })} data-id={status.get('id')}>
            {(connectReply || connectUp || connectToRoot) && <div className={classNames('status__line', { 'status__line--full': connectReply, 'status__line--first': !status.get('in_reply_to_id') && !connectToRoot })} />}

            {/* eslint-disable-next-line jsx-a11y/no-static-element-interactions */}
            <div onClick={this.handleClick} className='status__info'>
              <a href={`/@${status.getIn(['account', 'acct'])}/${status.get('id')}`} className='status__relative-time' target='_blank' rel='noopener noreferrer'>
                <span className='status__visibility-icon'><VisibilityIcon visibility={status.get('visibility')} /></span>
                <RelativeTimestamp timestamp={status.get('created_at')} />{status.get('edited_at') && <abbr title={intl.formatMessage(messages.edited, { date: intl.formatDate(status.get('edited_at'), { year: 'numeric', month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }) })}> *</abbr>}
              </a>

              <a onClick={this.handleAccountClick} href={`/@${status.getIn(['account', 'acct'])}`} title={status.getIn(['account', 'acct'])} className='status__display-name' target='_blank' rel='noopener noreferrer'>
                <div className='status__avatar'>
                  {statusAvatar}
                </div>

                <DisplayName account={status.get('account')} />
              </a>
            </div>

            <StatusContent
              status={status}
              onClick={this.handleClick}
              expanded={expanded}
              onExpandedToggle={this.handleExpandedToggle}
              onTranslate={this.handleTranslate}
              collapsible
              onCollapsedToggle={this.handleCollapsedToggle}
              {...statusContentProps}
            />

            {media}

            {expanded && hashtagBar}

            <StatusActionBar scrollKey={scrollKey} status={status} account={account} onFilter={matchedFilters ? this.handleFilterClick : null} {...other} />
          </div>
        </div>
      </HotKeys>
    );
  }

}

export default withOptionalRouter(injectIntl(Status));
