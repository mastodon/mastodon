import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import { DisplayName } from '@/mastodon/components/display_name';
import FlagIcon from '@/material-icons/400-24px/flag-fill.svg?react';
import { Icon } from 'mastodon/components/icon';
import { RelativeTimestamp } from 'mastodon/components/relative_timestamp';
import type { NotificationGroupAdminReport } from 'mastodon/models/notification_group';
import { useAppSelector } from 'mastodon/store';

// This needs to be kept in sync with app/models/report.rb
const messages = defineMessages({
  other: {
    id: 'report_notification.categories.other_sentence',
    defaultMessage: 'other',
  },
  spam: {
    id: 'report_notification.categories.spam_sentence',
    defaultMessage: 'spam',
  },
  legal: {
    id: 'report_notification.categories.legal_sentence',
    defaultMessage: 'illegal content',
  },
  violation: {
    id: 'report_notification.categories.violation_sentence',
    defaultMessage: 'rule violation',
  },
});

export const NotificationAdminReport: React.FC<{
  notification: NotificationGroupAdminReport;
  unread?: boolean;
}> = ({ notification, notification: { report }, unread }) => {
  const intl = useIntl();
  const targetAccount = useAppSelector((state) =>
    state.accounts.get(report.targetAccountId),
  );
  const account = useAppSelector((state) =>
    state.accounts.get(notification.sampleAccountIds[0] ?? '0'),
  );

  if (!account || !targetAccount) return null;

  const values = {
    name: <DisplayName account={account} variant='simple' />,
    target: <DisplayName account={targetAccount} variant='simple' />,
    category: intl.formatMessage(messages[report.category]),
    count: report.status_ids.length,
  };

  let message;

  if (report.status_ids.length > 0) {
    if (report.category === 'other') {
      message = (
        <FormattedMessage
          id='notification.admin.report_account_other'
          defaultMessage='{name} reported {count, plural, one {one post} other {# posts}} from {target}'
          values={values}
        />
      );
    } else {
      message = (
        <FormattedMessage
          id='notification.admin.report_account'
          defaultMessage='{name} reported {count, plural, one {one post} other {# posts}} from {target} for {category}'
          values={values}
        />
      );
    }
  } else {
    if (report.category === 'other') {
      message = (
        <FormattedMessage
          id='notification.admin.report_statuses_other'
          defaultMessage='{name} reported {target}'
          values={values}
        />
      );
    } else {
      message = (
        <FormattedMessage
          id='notification.admin.report_statuses'
          defaultMessage='{name} reported {target} for {category}'
          values={values}
        />
      );
    }
  }

  return (
    <a
      href={`/admin/reports/${report.id}`}
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
            <RelativeTimestamp timestamp={report.created_at} />
          </div>
        </div>

        {report.comment.length > 0 && (
          <div className='notification-group__embedded-status__content'>
            “{report.comment}”
          </div>
        )}
      </div>
    </a>
  );
};
