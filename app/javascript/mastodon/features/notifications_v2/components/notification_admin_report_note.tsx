import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import FlagIcon from '@/material-icons/400-24px/flag-fill.svg?react';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import type { NotificationGroupAdminReportNote } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

export const NotificationAdminReportNote: React.FC<{
  notification: NotificationGroupAdminReportNote;
  unread?: boolean;
}> = ({ notification, notification: { reportNote }, unread }) => {
  const account = useAppSelector((state) =>
    state.accounts.get(notification.sampleAccountIds[0] ?? '0'),
  );

  if (!account) return null;

  const domain = account.acct.split('@')[1];

  const values = {
    name: <bdi>{domain ?? `@${account.acct}`}</bdi>,
    reportId: reportNote.report.id,
  };

  const message = (
    <FormattedMessage
      id='notification.admin.report_note'
      defaultMessage='{name} added a report note to Report #{reportId}'
      values={values}
    />
  );

  return (
    <a
      href={`/admin/reports/${reportNote.report.id}#report_note_${reportNote.id}`}
      target='_blank'
      rel='noopener noreferrer'
      className={classNames(
        'notification-group notification-group--link notification-group--admin-report focusable',
        { 'notification-group--unread': unread },
      )}
    >
      <div className='notification-group__icon'>
        <Icon id='flag' icon={FlagIcon} />
      </div>

      <div className='notification-group__main'>
        <div className='notification-group__main__header'>
          <div className='notification-group__main__header__label'>
            {message}
            <RelativeTimestamp timestamp={reportNote.created_at} />
          </div>
        </div>

        {reportNote.content.length > 0 && (
          <div className='notification-group__embedded-status__content'>
            “{reportNote.content}”
          </div>
        )}
      </div>
    </a>
  );
};
