import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { Avatar } from 'flavours/glitch/components/avatar';
import { DisplayName } from 'flavours/glitch/components/display_name';
import MediaAttachments from 'flavours/glitch/components/media_attachments';
import { RelativeTimestamp } from 'flavours/glitch/components/relative_timestamp';
import StatusContent from 'flavours/glitch/components/status_content';
import VisibilityIcon from 'flavours/glitch/components/status_visibility_icon';

import Option from './option';

export default class StatusCheckBox extends PureComponent {

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

    if (status.get('reblog')) {
      return null;
    }

    const labelComponent = (
      <div className='status-check-box__status poll__option__text'>
        <div className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'>
            <Avatar account={status.get('account')} size={46} />
          </div>

          <div><DisplayName account={status.get('account')} /> · <VisibilityIcon visibility={status.get('visibility')} /><RelativeTimestamp timestamp={status.get('created_at')} /></div>
        </div>

        <StatusContent status={status} media={<MediaAttachments status={status} revealed={false} />} />
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
