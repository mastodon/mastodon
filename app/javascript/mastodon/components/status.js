import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import RelativeTimestamp from './relative_timestamp';
import DisplayName from './display_name';
import MediaGallery from './media_gallery';
import VideoPlayer from './video_player';
import AttachmentList from './attachment_list';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import { FormattedMessage } from 'react-intl';
import emojify from '../emoji';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';
import scheduleIdleTask from '../features/ui/util/schedule_idle_task';

class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.map,
    wrapped: PropTypes.bool,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    me: PropTypes.number,
    boostModal: PropTypes.bool,
    autoPlayGif: PropTypes.bool,
    muted: PropTypes.bool,
    intersectionObserverWrapper: PropTypes.object,
  };

  state = {
    isIntersecting: true, // assume intersecting until told otherwise
    isHidden: false, // set to true in requestIdleCallback to trigger un-render
  }

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'wrapped',
    'me',
    'boostModal',
    'autoPlayGif',
    'muted',
  ]

  updateOnStates = []

  shouldComponentUpdate (nextProps, nextState) {
    if (!nextState.isIntersecting && nextState.isHidden) {
      // It's only if we're not intersecting (i.e. offscreen) and isHidden is true
      // that either "isIntersecting" or "isHidden" matter, and then they're
      // the only things that matter.
      return this.state.isIntersecting || !this.state.isHidden;
    } else if (nextState.isIntersecting && !this.state.isIntersecting) {
      // If we're going from a non-intersecting state to an intersecting state,
      // (i.e. offscreen to onscreen), then we definitely need to re-render
      return true;
    }
    // Otherwise, diff based on "updateOnProps" and "updateOnStates"
    return super.shouldComponentUpdate(nextProps, nextState);
  }

  componentDidMount () {
    if (!this.props.intersectionObserverWrapper) {
      // TODO: enable IntersectionObserver optimization for notification statuses.
      // These are managed in notifications/index.js rather than status_list.js
      return;
    }
    this.props.intersectionObserverWrapper.observe(
      this.props.id,
      this.node,
      this.handleIntersection
    );
  }

  handleIntersection = (entry) => {
    // Edge 15 doesn't support isIntersecting, but we can infer it from intersectionRatio
    // https://developer.microsoft.com/en-us/microsoft-edge/platform/issues/12156111/
    const isIntersecting = entry.intersectionRatio > 0;
    this.setState((prevState) => {
      if (prevState.isIntersecting && !isIntersecting) {
        scheduleIdleTask(this.hideIfNotIntersecting);
      }
      return {
        isIntersecting: isIntersecting,
        isHidden: false,
      };
    });
  }

  hideIfNotIntersecting = () => {
    // When the browser gets a chance, test if we're still not intersecting,
    // and if so, set our isHidden to true to trigger an unrender. The point of
    // this is to save DOM nodes and avoid using up too much memory.
    // See: https://github.com/tootsuite/mastodon/issues/2900
    this.setState((prevState) => ({ isHidden: !prevState.isIntersecting }));
  }


  handleRef = (node) => {
    this.node = node;
    if (node && node.children.length !== 0) {
      this.height = node.clientHeight;
    }
  }

  handleClick = () => {
    const { status } = this.props;
    this.context.router.push(`/statuses/${status.getIn(['reblog', 'id'], status.get('id'))}`);
  }

  handleAccountClick = (e) => {
    if (e.button === 0) {
      const id = Number(e.currentTarget.getAttribute('data-id'));
      e.preventDefault();
      this.context.router.push(`/accounts/${id}`);
    }
  }

  render () {
    let media = null;
    let statusAvatar;
    const { status, account, ...other } = this.props;
    const { isIntersecting, isHidden } = this.state;

    if (status === null) {
      return null;
    }

    if (!isIntersecting && isHidden) {
      return (
        <div ref={this.handleRef} data-id={status.get('id')} style={{ height: `${this.height}px`, opacity: 0, overflow: 'hidden' }}>
          {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
          {status.get('content')}
        </div>
      );
    }

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      let displayName = status.getIn(['account', 'display_name']);

      if (displayName.length === 0) {
        displayName = status.getIn(['account', 'username']);
      }

      const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };

      return (
        <div className='status__wrapper' ref={this.handleRef} data-id={status.get('id')} >
          <div className='status__prepend'>
            <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-retweet status__prepend-icon' /></div>
            <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name muted'><strong dangerouslySetInnerHTML={displayNameHTML} /></a> }} />
          </div>

          <Status {...other} wrapped={true} status={status.get('reblog')} account={status.get('account')} />
        </div>
      );
    }

    if (status.get('media_attachments').size > 0 && !this.props.muted) {
      if (status.get('media_attachments').some(item => item.get('type') === 'unknown')) {

      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        media = <VideoPlayer media={status.getIn(['media_attachments', 0])} sensitive={status.get('sensitive')} onOpenVideo={this.props.onOpenVideo} />;
      } else {
        media = <MediaGallery media={status.get('media_attachments')} sensitive={status.get('sensitive')} height={110} onOpenMedia={this.props.onOpenMedia} autoPlayGif={this.props.autoPlayGif} />;
      }
    }

    if (account === undefined || account === null) {
      statusAvatar = <Avatar src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} size={48}/>;
    }else{
      statusAvatar = <AvatarOverlay staticSrc={status.getIn(['account', 'avatar_static'])} overlaySrc={account.get('avatar_static')} />;
    }

    return (
      <div className={`status ${this.props.muted ? 'muted' : ''} status-${status.get('visibility')}`} data-id={status.get('id')} ref={this.handleRef}>
        <div className='status__info'>
          <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>

          <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name'>
            <div className='status__avatar'>
              {statusAvatar}
            </div>

            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <StatusContent status={status} onClick={this.handleClick} />

        {media}

        <StatusActionBar {...this.props} />
      </div>
    );
  }

}

export default Status;
