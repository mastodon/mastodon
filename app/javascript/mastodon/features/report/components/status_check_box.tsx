import { Avatar } from '@/mastodon/components/avatar';
import { DisplayName } from '@/mastodon/components/display_name';
import { RelativeTimestamp } from '@/mastodon/components/relative_timestamp';
import { StatusAttachments } from '@/mastodon/components/status/attachments';
import { StatusContent } from '@/mastodon/components/status/content';
import { VisibilityIcon } from '@/mastodon/components/visibility_icon';
import { useAccountStatus } from '@/mastodon/hooks/useStatus';

import Option from './option';

export const StatusCheckBox: React.FC<{
  id: string;
  checked: boolean;
  onToggle: () => void;
}> = ({ id, checked, onToggle }) => {
  const status = useAccountStatus(id);

  if (!status || status.reblog) {
    return null;
  }

  const labelComponent = (
    <div className='status-check-box__status poll__option__text'>
      <div className='detailed-status__display-name'>
        <div className='detailed-status__display-avatar'>
          <Avatar account={status.account} size={46} />
        </div>

        <div>
          <DisplayName account={status.account} /> ·{' '}
          <span className='status__visibility-icon'>
            <VisibilityIcon visibility={status.visibility} />
          </span>{' '}
          <RelativeTimestamp timestamp={status.created_at} />
        </div>
      </div>

      <StatusContent status={status} />
      <StatusAttachments statusId={status.id} />
    </div>
  );

  return (
    <Option
      name='status_ids'
      value={status.id}
      checked={checked}
      onToggle={onToggle}
      label={status.search_index}
      labelComponent={labelComponent}
      multiple
    />
  );
};
