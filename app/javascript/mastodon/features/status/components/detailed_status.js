import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import StatusContent from '../../../components/status_content';
import MediaGallery from '../../../components/media_gallery';
import { Link } from 'react-router-dom';
import { FormattedDate } from 'react-intl';
import Card from './card';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Video from '../../video';
import Audio from '../../audio';
import scheduleIdleTask from '../../ui/util/schedule_idle_task';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';
import AnimatedNumber from 'mastodon/components/animated_number';

export default class DetailedStatus extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    onOpenMedia: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
    onToggleHidden: PropTypes.func.isRequired,
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
    if (e.button === 0 && !(e.ctrlKey || e.metaKey) && this.context.router) {
      e.preventDefault();
      this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }

    e.stopPropagation();
  }

  handleOpenVideo = (media, options) => {
    this.props.onOpenVideo(media, options);
  }

  handleExpandedToggle = () => {
    this.props.onToggleHidden(this.props.status);
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
    const outerStyle = { boxSizing: 'border-box' };
    const { compact } = this.props;

    if (!status) {
      return null;
    }

    let media           = '';
    let applicationLink = '';
    let reblogLink = '';
    let reblogIcon = 'retweet';
    let favouriteLink = '';

    if (this.props.measureHeight) {
      outerStyle.height = `${this.state.height}px`;
    }

    if (status.get('media_attachments').size > 0) {
      if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Audio
            src={attachment.get('url')}
            alt={attachment.get('description')}
            duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
            height={110}
            data={attachment.get('waveform')}
          />
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);

        media = (
          <Video
            preview={attachment.get('preview_url')}
            blurhash={attachment.get('blurhash')}
            src={attachment.get('url')}
            alt={attachment.get('description')}
            width={300}
            height={150}
            inline
            onOpenVideo={this.handleOpenVideo}
            sensitive={status.get('sensitive')}
            visible={this.props.showMedia}
            onToggleVisibility={this.props.onToggleMediaVisibility}
          />
        );
      } else {
        media = (
          <MediaGallery
            standalone
            sensitive={status.get('sensitive')}
            media={status.get('media_attachments')}
            height={300}
            onOpenMedia={this.props.onOpenMedia}
            visible={this.props.showMedia}
            onToggleVisibility={this.props.onToggleMediaVisibility}
          />
        );
      }
    } else if (status.get('spoiler_text').length === 0) {
      media = <Card sensitive={status.get('sensitive')} onOpenMedia={this.props.onOpenMedia} card={status.get('card', null)} />;
    }

    if (status.get('application')) {
      applicationLink = <span> · <a className='detailed-status__application' href={status.getIn(['application', 'website'])} target='_blank' rel='noopener noreferrer'>{status.getIn(['application', 'name'])}</a></span>;
    }

    if (status.get('visibility') === 'direct') {
      reblogIcon = 'envelope';
    } else if (status.get('visibility') === 'private') {
      reblogIcon = 'lock';
    }

    if (['private', 'direct'].includes(status.get('visibility'))) {
      reblogLink = <Icon id={reblogIcon} />;
    } else if (this.context.router) {
      reblogLink = (
        <Link to={`/statuses/${status.get('id')}/reblogs`} className='detailed-status__link'>
          <Icon id={reblogIcon} />
          <span className='detailed-status__reblogs'>
            <AnimatedNumber value={status.get('reblogs_count')} />
          </span>
        </Link>
      );
    } else {
      reblogLink = (
        <a href={`/interact/${status.get('id')}?type=reblog`} className='detailed-status__link' onClick={this.handleModalLink}>
          <Icon id={reblogIcon} />
          <span className='detailed-status__reblogs'>
            <AnimatedNumber value={status.get('reblogs_count')} />
          </span>
        </a>
      );
    }

    if (this.context.router) {
      favouriteLink = (
        <Link to={`/statuses/${status.get('id')}/favourites`} className='detailed-status__link'>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <AnimatedNumber value={status.get('favourites_count')} />
          </span>
        </Link>
      );
    } else {
      favouriteLink = (
        <a href={`/interact/${status.get('id')}?type=favourite`} className='detailed-status__link' onClick={this.handleModalLink}>
          <Icon id='star' />
          <span className='detailed-status__favorites'>
            <AnimatedNumber value={status.get('favourites_count')} />
          </span>
        </a>
      );
    }

    return (
      <div style={outerStyle}>
        <div ref={this.setRef} className={classNames('detailed-status', { compact })}>
          <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='detailed-status__display-name'>
            <div className='detailed-status__display-avatar'><Avatar account={status.get('account')} size={48} /></div>
            <DisplayName account={status.get('account')} localDomain={this.props.domain} />
          </a>

          <StatusContent status={status} expanded={!status.get('hidden')} onExpandedToggle={this.handleExpandedToggle} />

          {media}

          <div className='detailed-status__meta'>
            <a className='detailed-status__datetime' href={status.get('url')} target='_blank' rel='noopener noreferrer'>
              <FormattedDate value={new Date(status.get('created_at'))} hour12={false} year='numeric' month='short' day='2-digit' hour='2-digit' minute='2-digit' />
            </a>{applicationLink} · {reblogLink} · {favouriteLink}
          </div>
        </div>
      </div>
    );
  }

}
