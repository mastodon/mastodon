import { useMemo } from 'react';
import Status from 'mastodon/containers/status_container';
import { Icon }  from 'mastodon/components/icon';
import { NamesList } from './names_list';
import { FormattedMessage } from 'react-intl';

export const NotificationWithStatus = ({
  icon,
  accountIds,
  statusId,
  count,
  labelRenderer,
  type,
}) => {
  const label = useMemo(() => labelRenderer({ name: <NamesList accountIds={accountIds} total={count} /> }), [labelRenderer, accountIds, count]);

  return (
    <div className={`notification-ungrouped focusable notification-ungrouped--${type}`} tabIndex='0'>
      <div className='notification-ungrouped__header'>
        <div className='notification-ungrouped__header__icon'><Icon icon={icon} /></div>
        {label}
      </div>

      <Status
        id={statusId}
        contextType='notifications'
        withDismiss
      />
    </div>
  );
};
