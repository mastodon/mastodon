import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import noop from 'lodash/noop';
import StatusContent from 'mastodon/components/status_content';
import { MediaGallery, Video } from 'mastodon/features/ui/util/async-components';
import Bundle from 'mastodon/features/ui/components/bundle';
import classNames from 'classnames';
import Avatar from 'mastodon/components/avatar';
import DisplayName from 'mastodon/components/display_name';
import RelativeTimestamp from 'mastodon/components/relative_timestamp';

export default class StatusCheckBox extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    status: ImmutablePropTypes.map.isRequired,
    checked: PropTypes.bool,
    onToggle: PropTypes.func.isRequired,
  };

  handleStatusesChange = e => {
    const { onToggle, id } = this.props;
    onToggle(id, e.target.checked);
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
                height={110}
                onOpenMedia={noop}
              />
            )}
          </Bundle>
        );
      }
    }

    return (
      <label className='dialog-option status-check-box poll__option selectable'>
        <input type='checkbox' name='status_ids' value={status.get('id')} checked={checked} onChange={this.handleStatusesChange} />

        <span
          className={classNames('poll__input checkbox', { active: checked })}
          tabIndex='0'
          role='checkbox'
          onKeyPress={this.handleRulesKeyPress}
          aria-checked={checked}
          aria-label={status.get('search_index')}
          data-value={status.get('id')}
        />

        <div className='status-check-box__status poll__option__text'>
          <div className='detailed-status__display-name'>
            <div className='detailed-status__display-avatar'>
              <Avatar account={status.get('account')} size={46} />
            </div>

            <div><DisplayName account={status.get('account')} /> · <RelativeTimestamp timestamp={status.get('created_at')} /></div>
          </div>

          <StatusContent status={status} />

          {media}
        </div>
      </label>
    );
  }

}
