import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import StatusContent from '../../../components/status_content';
import MediaGallery from '../../../components/media_gallery';
import VideoPlayer from '../../../components/video_player';
import AttachmentList from '../../../components/attachment_list';
import Link from 'react-router/lib/Link';
import { FormattedDate, FormattedNumber } from 'react-intl';
import CardContainer from '../containers/card_container';
import ImmutablePureComponent from 'react-immutable-pure-component';

class DetailedStatus extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
    autoPlayGif: PropTypes.bool,
  };

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }

    e.stopPropagation();
  }

  render () {
    const status = this.props.status.get('reblog') ? this.props.status.get('reblog') : this.props.status;

    let media           = '';
    let applicationLink = '';

    if (status.get('media_attachments').size > 0) {
      if (status.get('media_attachments').some(item => item.get('type') === 'unknown')) {
        media = <AttachmentList media={status.get('media_attachments')} />;
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        media = <VideoPlayer sensitive={status.get('sensitive')} media={status.getIn(['media_attachments', 0])} width={300} height={150} onOpenVideo={this.props.onOpenVideo} autoplay />;
      } else {
        media = <MediaGallery sensitive={status.get('sensitive')} media={status.get('media_attachments')} height={300} onOpenMedia={this.props.onOpenMedia} autoPlayGif={this.props.autoPlayGif} />;
      }
    } else if (status.get('spoiler_text').length === 0) {
      media = <CardContainer statusId={status.get('id')} />;
    }

    if (status.get('application')) {
      applicationLink = <span> · <a className='detailed-status__application' href={status.getIn(['application', 'website'])} target='_blank' rel='noopener'>{status.getIn(['application', 'name'])}</a></span>;
    }

    return (
      <div className='detailed-status'>
        <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'><Avatar src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} size={48} /></div>
          <DisplayName account={status.get('account')} />
        </a>

        <StatusContent status={status} />

        {media}

        <div className='detailed-status__meta'>
          <a className='detailed-status__datetime' href={status.get('url')} target='_blank' rel='noopener'>
            <FormattedDate value={new Date(status.get('created_at'))} hour12={false} year='numeric' month='short' day='2-digit' hour='2-digit' minute='2-digit' />
          </a>{applicationLink} · <Link to={`/statuses/${status.get('id')}/reblogs`} className='detailed-status__link'>
            <i className='fa fa-retweet' />
            <span className='detailed-status__reblogs'>
              <FormattedNumber value={status.get('reblogs_count')} />
            </span>
          </Link> · <Link to={`/statuses/${status.get('id')}/favourites`} className='detailed-status__link'>
            <i className='fa fa-star' />
            <span className='detailed-status__favorites'>
              <FormattedNumber value={status.get('favourites_count')} />
            </span>
          </Link>
        </div>
      </div>
    );
  }

}

export default DetailedStatus;
