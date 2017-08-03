import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import RelativeTimestamp from './relative_timestamp';
import DisplayName from './display_name';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import { FormattedMessage } from 'react-intl';
import emojify from '../emoji';
import escapeTextContentForBrowser from 'escape-html';
import ImmutablePureComponent from 'react-immutable-pure-component';
import scheduleIdleTask from '../features/ui/util/schedule_idle_task';
import { MediaGallery, VideoPlayer } from '../features/ui/util/async-components';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';
import getRectFromEntry from '../features/ui/util/get_rect_from_entry';

export default class Status extends ImmutablePureComponent {

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
    index: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    listLength: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  };

  state = {
    isExpanded: false,
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
    'listLength',
  ]

  updateOnStates = ['isExpanded']

  shouldComponentUpdate (nextProps, nextState) {
    if (!nextState.isIntersecting && nextState.isHidden) {
      // It's only if we're not intersecting (i.e. offscreen) and isHidden is true
      // that either "isIntersecting" or "isHidden" matter, and then they're
      // the only things that matter (and updated ARIA attributes).
      return this.state.isIntersecting || !this.state.isHidden || nextProps.listLength !== this.props.listLength;
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

    this.componentMounted = true;
  }

  componentWillUnmount () {
    if (this.props.intersectionObserverWrapper) {
      this.props.intersectionObserverWrapper.unobserve(this.props.id, this.node);
    }

    this.componentMounted = false;
  }

  handleIntersection = (entry) => {
    if (this.node && this.node.children.length !== 0) {
      // save the height of the fully-rendered element
      this.height = getRectFromEntry(entry).height;
    }

    this.setState((prevState) => {
      if (prevState.isIntersecting && !entry.isIntersecting) {
        scheduleIdleTask(this.hideIfNotIntersecting);
      }
      return {
        isIntersecting: entry.isIntersecting,
        isHidden: false,
      };
    });
  }

  hideIfNotIntersecting = () => {
    if (!this.componentMounted) {
      return;
    }

    // When the browser gets a chance, test if we're still not intersecting,
    // and if so, set our isHidden to true to trigger an unrender. The point of
    // this is to save DOM nodes and avoid using up too much memory.
    // See: https://github.com/tootsuite/mastodon/issues/2900
    this.setState((prevState) => ({ isHidden: !prevState.isIntersecting }));
  }

  handleRef = (node) => {
    this.node = node;
  }

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { status } = this.props;
    this.context.router.history.push(`/statuses/${status.getIn(['reblog', 'id'], status.get('id'))}`);
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0) {
      const id = Number(e.currentTarget.getAttribute('data-id'));
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

  render () {
    let media = null;
    let statusAvatar;

    // Exclude intersectionObserverWrapper from `other` variable
    // because intersection is managed in here.
    const { status, account, intersectionObserverWrapper, index, listLength, wrapped, ...other } = this.props;
    const { isExpanded, isIntersecting, isHidden } = this.state;

    if (status === null) {
      return null;
    }

    if (!isIntersecting && isHidden) {
      return (
        <article ref={this.handleRef} data-id={status.get('id')} aria-posinset={index} aria-setsize={listLength} tabIndex='0' style={{ height: `${this.height}px`, opacity: 0, overflow: 'hidden' }}>
          {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
          {status.get('content')}
        </article>
      );
    }

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      let displayName = status.getIn(['account', 'display_name']);

      if (displayName.length === 0) {
        displayName = status.getIn(['account', 'username']);
      }

      const displayNameHTML = { __html: emojify(escapeTextContentForBrowser(displayName)) };

      return (
        <article className='status__wrapper' ref={this.handleRef} data-id={status.get('id')} aria-posinset={index} aria-setsize={listLength} tabIndex='0'>
          <div className='status__prepend'>
            <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-retweet status__prepend-icon' /></div>
            <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name muted'><strong dangerouslySetInnerHTML={displayNameHTML} /></a> }} />
          </div>

          <Status {...other} wrapped status={status.get('reblog')} account={status.get('account')} />
        </article>
      );
    }

    if (status.get('media_attachments').size > 0 && !this.props.muted) {
      if (status.get('media_attachments').some(item => item.get('type') === 'unknown')) {

      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        media = (
          <Bundle fetchComponent={VideoPlayer} loading={this.renderLoadingVideoPlayer} >
            {Component => <Component media={status.getIn(['media_attachments', 0])} sensitive={status.get('sensitive')} onOpenVideo={this.props.onOpenVideo} />}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => <Component media={status.get('media_attachments')} sensitive={status.get('sensitive')} height={110} onOpenMedia={this.props.onOpenMedia} autoPlayGif={this.props.autoPlayGif} />}
          </Bundle>
        );
      }
    }

    if (account === undefined || account === null) {
      statusAvatar = <Avatar src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} size={48} />;
    }else{
      statusAvatar = <AvatarOverlay staticSrc={status.getIn(['account', 'avatar_static'])} overlaySrc={account.get('avatar_static')} />;
    }

    return (
      <article aria-posinset={index} aria-setsize={listLength} className={`status ${this.props.muted ? 'muted' : ''} status-${status.get('visibility')}`} data-id={status.get('id')} tabIndex={wrapped ? null : '0'}  ref={this.handleRef}>
        <div className='status__info'>
          <a href={status.get('url')} className='status__relative-time' target='_blank' rel='noopener'><RelativeTimestamp timestamp={status.get('created_at')} /></a>

          <a onClick={this.handleAccountClick} target='_blank' data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name'>
            <div className='status__avatar'>
              {statusAvatar}
            </div>

            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <StatusContent status={status} onClick={this.handleClick} expanded={isExpanded} onExpandedToggle={this.handleExpandedToggle} />

        {media}

        <StatusActionBar {...this.props} />
      </article>
    );
  }

}
