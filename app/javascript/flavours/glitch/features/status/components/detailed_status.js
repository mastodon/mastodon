import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from 'flavours/glitch/components/avatar';
import DisplayName from 'flavours/glitch/components/display_name';
import StatusContent from 'flavours/glitch/components/status_content';
import MediaGallery from 'flavours/glitch/components/media_gallery';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import { Link } from 'react-router-dom';
import { FormattedDate, FormattedNumber } from 'react-intl';
import Card from './card';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Video from 'flavours/glitch/features/video';
import Audio from 'flavours/glitch/features/audio';
import VisibilityIcon from 'flavours/glitch/components/status_visibility_icon';
import scheduleIdleTask from 'flavours/glitch/util/schedule_idle_task';
import classNames from 'classnames';
import PollContainer from 'flavours/glitch/containers/poll_container';
import Icon from 'flavours/glitch/components/icon';

export default class DetailedStatus extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    settings: ImmutablePropTypes.map.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
    onToggleHidden: PropTypes.func,
    expanded: PropTypes.bool,
    measureHeight: PropTypes.bool,
    onHeightChange: PropTypes.func,
    domain: PropTypes.string.isRequired,
    compact: PropTypes.bool,
    showMedia: PropTypes.bool,
    onToggleMediaVisibility: PropTypes.func,
  };

  state = {
    height: null,
  };

  handleAccountClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.altKey || e.metaKey) && this.context.router) {
      e.preventDefault();
      let state = {...this.context.router.history.location.state};
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`, state);
    }

    e.stopPropagation();
  }

  parseClick = (e, destination) => {
    if (e.button === 0 && !(e.ctrlKey || e.altKey || e.metaKey) && this.context.router) {
      e.preventDefault();
      let state = {...this.context.router.history.location.state};
      state.mastodonBackSteps = (state.mastodonBackSteps || 0) + 1;
      this.context.router.history.push(destination, state);
    }

    e.stopPropagation();
  }

  handleOpenVideo = (media, startTime) => {
    this.props.onOpenVideo(media, startTime);
  }

  _measureHeight (heightJustChanged) {
    if (this.props.measureHeight && this.node) {
      scheduleIdleTask(() => this.node && this.setState({ height: Math.ceil(this.node.scrollHeight) + 1 }));

      if (this.props.onHeightChange && heightJustChanged) {
        this.props.onHeightChange();
      }
    }
  }

  setRef = c => {
    this.node = c;
    this._measureHeight();
  }

  componentDidUpdate (prevProps, prevState) {
    this._measureHeight(prevState.height !== this.state.height);
  }

  handleChildUpdate = () => {
    this._measureHeight();
  }

  handleModalLink = e => {
    e.preventDefault();

    let href;

    if (e.target.nodeName !== 'A') {
      href = e.target.parentNode.href;
    } else {
      href = e.target.href;
    }

    window.open(href, 'mastodon-intent', 'width=445,height=600,resizable=no,menubar=no,status=no,scrollbars=yes');
  }

  render () {
    const status = (this.props.status && this.props.status.get('reblog')) ? this.props.status.get('reblog') : this.props.status;
    const { expanded, onToggleHidden, settings } = this.props;
    const outerStyle = { boxSizing: 'border-box' };
    const { compact } = this.props;

    if (!status) {
      return null;
    }

    let media           = null;
    let mediaIcon       = null;
    let applicationLink = '';
    let reblogLink = '';
    let reblogIcon = 'retweet';
    let favouriteLink = '';

    if (this.props.measureHeight) {
      outerStyle.height = `${this.state.height}px`;
    }

    if (status.get('poll')) {
      media = <PollContainer pollId={status.get('poll')} />;
      mediaIcon = 'tasks';
    } else if (status.get('media_attachments').size > 0) {
      if (status.get('media_attachments').some(item => item.get('type') === 'unknown')) {
        media = <AttachmentList media={status.get('media_attachments')} />;
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Audio
            src={attachment.get('url')}
            alt={attachment.get('description')}
            duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
            height={110}
            preload
          />
        );
        mediaIcon = 'music';
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);
        media = (
          <Video
            preview={attachment.get('preview_url')}
            blurhash={attachment.get('blurhash')}
            src={attachment.get('url')}
            alt={attachment.get('description')}
            inline
            sensitive={status.get('sensitive')}
            letterbox={settings.getIn(['media', 'letterbox'])}
            fullwidth={settings.getIn(['media', 'fullwidth'])}
            preventPlayback={!expanded}
            onOpenVideo={this.handleOpenVideo}
            autoplay
            visible={this.props.showMedia}
            onToggleVisibility={this.props.onToggleMediaVisibility}
          />
        );
        mediaIcon = 'video-camera';
      } else {
        media = (
          <MediaGallery
            standalone
            sensitive={status.get('sensitive')}
            media={status.get('media_attachments')}
            letterbox={settings.getIn(['media', 'letterbox'])}
            fullwidth={settings.getIn(['media', 'fullwidth'])}
            hidden={!expanded}
            onOpenMedia={this.props.onOpenMedia}
            visible={this.props.showMedia}
            onToggleVisibility={this.props.onToggleMediaVisibility}
          />
        );
        mediaIcon = 'picture-o';
      }
    } else if (status.get('card')) {
      media = <Card onOpenMedia={this.props.onOpenMedia} card={status.get('card')} />;
      mediaIcon = 'link';
    }

    if (status.get('application')) {
      applicationLink = <span> · <a className='detailed-status__application' href={status.getIn(['application', 'website'])} target='_blank' rel='noopener'>{status.getIn(['application', 'name'])}</a></span>;
    }

    if (status.get('visibility') === 'direct') {
      reblogIcon = 'envelope';
    } else if (status.get('visibility') === 'private') {
      reblogIcon = 'lock';
    }

    if (status.get('visibility') === 'private') {
      reblogLink = <Icon id={reblogIcon} />;
    } else if (this.context.router) {
      reblogLink = (
        <Link to={`/statuses/${status.get('id')}/reblogs`} className='detailed-status__link'>
          <Icon id={reblogIcon} />
          <span className='detailed-status__reblogs'>
            <FormattedNumber value={status.get('reblogs_count')} />
          </span>
        </Link>
      );
    } else {
      reblogLink = (
        <a href={`/interact/${status.get('id')}?type=reblog`} className='detailed-status__link' onClick={this.handleModalLink}>
          <Icon id={reblogIcon} />
          <span className='detailed-status__reblogs'>
            <FormattedNumber value={status.get('reblogs_count')} />
          </span>
        </a>
      );
    }

    if (this.context.router) {
      favouriteLink = (
        <Link to={`/statuses/${status.get('id')}/favourites`} className='detailed-status__link'>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <FormattedNumber value={status.get('favourites_count')} />
          </span>
        </Link>
      );
    } else {
      favouriteLink = (
        <a href={`/interact/${status.get('id')}?type=favourite`} className='detailed-status__link' onClick={this.handleModalLink}>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <FormattedNumber value={status.get('favourites_count')} />
          </span>
        </a>
      );
    }

    return (
      <div style={outerStyle}>
        <div ref={this.setRef} className={classNames('detailed-status', { compact })} data-status-by={status.getIn(['account', 'acct'])}>
          <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='detailed-status__display-name'>
            <div className='detailed-status__display-avatar'><Avatar account={status.get('account')} size={48} /></div>
            <DisplayName account={status.get('account')} localDomain={this.props.domain} />
          </a>

          <StatusContent
            status={status}
            media={media}
            mediaIcon={mediaIcon}
            expanded={expanded}
            collapsed={false}
            onExpandedToggle={onToggleHidden}
            parseClick={this.parseClick}
            onUpdate={this.handleChildUpdate}
            tagLinks={settings.get('tag_misleading_links')}
            rewriteMentions={settings.get('rewrite_mentions')}
            disabled
          />

          <div className='detailed-status__meta'>
            <a className='detailed-status__datetime' href={status.get('url')} target='_blank' rel='noopener'>
              <FormattedDate value={new Date(status.get('created_at'))} hour12={false} year='numeric' month='short' day='2-digit' hour='2-digit' minute='2-digit' />
            </a>{applicationLink} · {reblogLink} · {favouriteLink} · <VisibilityIcon visibility={status.get('visibility')} />
          </div>
        </div>
      </div>
    );
  }

}
