import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import noop from 'lodash/noop';
import StatusContent from 'flavours/glitch/components/status_content';
import { MediaGallery, Video } from 'flavours/glitch/util/async-components';
import Bundle from 'flavours/glitch/features/ui/components/bundle';
import Avatar from 'flavours/glitch/components/avatar';
import DisplayName from 'flavours/glitch/components/display_name';
import RelativeTimestamp from 'flavours/glitch/components/relative_timestamp';
import Option from './option';

export default class StatusCheckBox extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    status: ImmutablePropTypes.map.isRequired,
    checked: PropTypes.bool,
    onToggle: PropTypes.func.isRequired,
  };

  handleStatusesToggle = (value, checked) => {
    const { onToggle } = this.props;
    onToggle(value, checked);
  };

  render () {
    const { status, checked } = this.props;

    let media = null;

    if (status.get('reblog')) {
      return null;
    }

    if (status.get('media_attachments').size > 0) {
      if (status.get('media_attachments').some(item => item.get('type') === 'unknown')) {

      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const video = status.getIn(['media_attachments', 0]);

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={video.get('preview_url')}
                blurhash={video.get('blurhash')}
                src={video.get('url')}
                alt={video.get('description')}
                width={239}
                height={110}
                inline
                sensitive={status.get('sensitive')}
                revealed={false}
                onOpenVideo={noop}
              />
            )}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => (
              <Component
                media={status.get('media_attachments')}
                sensitive={status.get('sensitive')}
                revealed={false}
                height={110}
                onOpenMedia={noop}
              />
            )}
          </Bundle>
        );
      }
    }

    const labelComponent = (
      <div className='status-check-box__status poll__option__text'>
        <div className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'>
            <Avatar account={status.get('account')} size={46} />
          </div>

          <div><DisplayName account={status.get('account')} /> · <RelativeTimestamp timestamp={status.get('created_at')} /></div>
        </div>

        <StatusContent status={status} media={media} />
      </div>
    );

    return (
      <Option
        name='status_ids'
        value={status.get('id')}
        checked={checked}
        onToggle={this.handleStatusesToggle}
        label={status.get('search_index')}
        labelComponent={labelComponent}
        multiple
      />
    );
  }

}
