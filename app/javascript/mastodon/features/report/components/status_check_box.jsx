import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';
import MediaAttachments from 'mastodon/components/media_attachments';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import StatusContent from 'mastodon/components/status_content';
import { VisibilityIcon } from 'mastodon/components/visibility_icon';

import Option from './option';

class StatusCheckBox extends PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    status: ImmutablePropTypes.map.isRequired,
    checked: PropTypes.bool,
    onToggle: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleStatusesToggle = (value, checked) => {
    const { onToggle } = this.props;
    onToggle(value, checked);
  };

  render () {
    const { status, checked } = this.props;

    if (status.get('reblog')) {
      return null;
    }

    const labelComponent = (
      <div className='status-check-box__status poll__option__text'>
        <div className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'>
            <Avatar account={status.get('account')} size={46} />
          </div>

          <div>
            <DisplayName account={status.get('account')} /> · <span className='status__visibility-icon'><VisibilityIcon visibility={status.get('visibility')} /></span> <RelativeTimestamp timestamp={status.get('created_at')} />
          </div>
        </div>

        <StatusContent status={status} />
        <MediaAttachments status={status} visible={false} />
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

export default StatusCheckBox;
