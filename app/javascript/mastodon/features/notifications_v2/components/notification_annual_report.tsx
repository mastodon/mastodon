import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import CelebrationIcon from '@/material-icons/400-24px/celebration.svg?react';
import { openModal } from 'mastodon/actions/modal';
import { Icon } from 'mastodon/components/icon';
import type { NotificationGroupAnnualReport } from 'mastodon/models/notification_group';
import { useAppDispatch } from 'mastodon/store';

export const NotificationAnnualReport: React.FC<{
  notification: NotificationGroupAnnualReport;
  unread: boolean;
}> = ({ notification: { annualReport }, unread }) => {
  const dispatch = useAppDispatch();
  const year = annualReport.year;

  const handleClick = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ANNUAL_REPORT',
        modalProps: { year },
      }),
    );
  }, [dispatch, year]);

  return (
    <div
      role='button'
      className={classNames(
        'notification-group notification-group--link notification-group--annual-report focusable',
        { 'notification-group--unread': unread },
      )}
      tabIndex={0}
    >
      <div className='notification-group__icon'>
        <Icon id='celebration' icon={CelebrationIcon} />
      </div>

      <div className='notification-group__main'>
        <p>
          <FormattedMessage
            id='notification.annual_report.message'
            defaultMessage="Your {year} #Wrapstodon awaits! Unveil your year's highlights and memorable moments on Mastodon!"
            values={{ year }}
          />
        </p>
        <button onClick={handleClick} className='link-button'>
          <FormattedMessage
            id='notification.annual_report.view'
            defaultMessage='View #Wrapstodon'
          />
        </button>
      </div>
    </div>
  );
};
