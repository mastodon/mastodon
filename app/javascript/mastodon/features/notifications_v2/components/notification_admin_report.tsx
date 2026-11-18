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
  local: {
    id: 'report_notification.target.local',
    defaultMessage: 'local',
  },
  remote: {
    id: 'report_notification.target.remote',
    defaultMessage: 'remote',
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

  const isLocal = !targetAccount.acct.includes('@');
  const locality = intl.formatMessage(isLocal ? messages.local : messages.remote);
  const name = <DisplayName account={account} variant='simple' />;
  const target = <DisplayName account={targetAccount} variant='simple' />;
  const category = intl.formatMessage(messages[report.category]);
  const count = report.status_ids.length;

  let message;

  if (report.status_ids.length > 0) {
    if (report.category === 'other') {
      message = (
        <FormattedMessage
          id='notification.admin.report_account_other'
          defaultMessage='{name} reported {count, plural, one {one post} other {# posts}} from {target} ({locality})'
          values={{ name, count, target, locality }}
        />
      );
    } else {
      message = (
        <FormattedMessage
          id='notification.admin.report_account'
          defaultMessage='{name} reported {count, plural, one {one post} other {# posts}} from {target} ({locality}) for {category}'
          values={{ name, count, target, category, locality }}
        />
      );
    }
  } else {
    if (report.category === 'other') {
      message = (
        <FormattedMessage
          id='notification.admin.report_statuses_other'
          defaultMessage='{name} reported {target} ({locality})'
          values={{ name, target, locality }}
        />
      );
    } else {
      message = (
        <FormattedMessage
          id='notification.admin.report_statuses'
          defaultMessage='{name} reported {target} ({locality}) for {category}'
          values={{ name, target, category, locality }}
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
          <h2 className='notification-group__main__header__label'>
            {message}
            <RelativeTimestamp timestamp={report.created_at} />
          </h2>
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
