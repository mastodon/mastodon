import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import RelativeTimestamp from './relative_timestamp';
import DisplayName from './display_name';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import AttachmentList from './attachment_list';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, Video } from '../features/ui/util/async-components';
import { HotKeys } from 'react-hotkeys';
import classNames from 'classnames';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

export default class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
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
    hidden: PropTypes.bool,
    onMoveUp: PropTypes.func,
    onMoveDown: PropTypes.func,
  };

  state = {
    isExpanded: false,
  }

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'muted',
    'hidden',
  ]

  updateOnStates = ['isExpanded']

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { status } = this.props;
    this.context.router.history.push(`/statuses/${status.getIn(['reblog', 'id'], status.get('id'))}`);
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0) {
      const id = e.currentTarget.getAttribute('data-id');
      e.preventDefault();
      this.context.router.history.push(`/accounts/${id}`);
    }
  }

  handleExpandedToggle = () => {
    this.setState({ isExpanded: !this.state.isExpanded });
  };

  renderLoadingMediaGallery () {
    return <div className='media_gallery' style={{ height: '110px' }} />;
  }

  renderLoadingVideoPlayer () {
    return <div className='media-spoiler-video' style={{ height: '110px' }} />;
  }

  handleOpenVideo = startTime => {
    this.props.onOpenVideo(this._properStatus().getIn(['media_attachments', 0]), startTime);
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
    this.context.router.history.push(`/statuses/${this._properStatus().get('id')}`);
  }

  handleHotkeyOpenProfile = () => {
    this.context.router.history.push(`/accounts/${this._properStatus().getIn(['account', 'id'])}`);
  }

  handleHotkeyMoveUp = () => {
    this.props.onMoveUp(this.props.status.get('id'));
  }

  handleHotkeyMoveDown = () => {
    this.props.onMoveDown(this.props.status.get('id'));
  }

  _properStatus () {
    const { status } = this.props;

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      return status.get('reblog');
    } else {
      return status;
    }
  }

  render () {
    let media = null;
    let statusAvatar, prepend;

    const { hidden, featured } = this.props;
    const { isExpanded } = this.state;

    let { status, account, ...other } = this.props;

    if (status === null) {
      return null;
    }

    if (hidden) {
      return (
        <div>
          {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
          {status.get('content')}
        </div>
      );
    }

    if (featured) {
      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-thumb-tack status__prepend-icon' /></div>
          <FormattedMessage id='status.pinned' defaultMessage='Pinned toot' />
        </div>
      );
    } else if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      const display_name_html = { __html: status.getIn(['account', 'display_name_html']) };

      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-retweet status__prepend-icon' /></div>
          <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name muted'><bdi><strong dangerouslySetInnerHTML={display_name_html} /></bdi></a> }} />
        </div>
      );

      account = status.get('account');
      status  = status.get('reblog');
    }

    if (status.get('media_attachments').size > 0) {
      if (this.props.muted || status.get('media_attachments').some(item => item.get('type') === 'unknown')) {
        media = (
          <AttachmentList
            compact
            media={status.get('media_attachments')}
          />
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const video = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={video.get('preview_url')}
                src={video.get('url')}
                width={239}
                height={110}
                inline
                sensitive={status.get('sensitive')}
                onOpenVideo={this.handleOpenVideo}
              />
            )}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => <Component media={status.get('media_attachments')} sensitive={status.get('sensitive')} height={110} onOpenMedia={this.props.onOpenMedia} />}
          </Bundle>
        );
      }
    }

    if (account === undefined || account === null) {
      statusAvatar = <Avatar account={status.get('account')} size={48} />;
    }else{
      statusAvatar = <AvatarOverlay account={status.get('account')} friend={account} />;
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
    };

    return (
      <HotKeys handlers={handlers}>
        <div className={classNames('status__wrapper', `status__wrapper-${status.get('visibility')}`, { focusable: !this.props.muted })} tabIndex={this.props.muted ? null : 0}>
          {prepend}

          <div className={classNames('status', `status-${status.get('visibility')}`, { muted: this.props.muted })} data-id={status.get('id')}>
            <div className='status__info'>
              <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>

              <a onClick={this.handleAccountClick} target='_blank' data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} title={status.getIn(['account', 'acct'])} className='status__display-name'>
                <div className='status__avatar'>
                  {statusAvatar}
                </div>

                <DisplayName account={status.get('account')} />
              </a>
            </div>

            <StatusContent status={status} onClick={this.handleClick} expanded={isExpanded} onExpandedToggle={this.handleExpandedToggle} />

            {media}

            <StatusActionBar status={status} account={account} {...other} />
          </div>
        </div>
      </HotKeys>
    );
  }

}
