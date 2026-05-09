import { useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { defineMessages, useIntl } from 'react-intl';
import { fetchScheduledStatuses, cancelScheduledStatus } from 'mastodon/actions/scheduled_statuses';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { Button } from 'mastodon/components/button';

const messages = defineMessages({
  heading: { id: 'scheduled_statuses.heading', defaultMessage: 'Scheduled posts' },
  cancel: { id: 'scheduled_statuses.cancel', defaultMessage: 'Cancel' },
  empty: { id: 'scheduled_statuses.empty', defaultMessage: 'No scheduled posts.' },
});

const ScheduledStatuses = ({ multiColumn }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const statuses = useSelector(s => s.get('scheduled_statuses'));

  useEffect(() => { dispatch(fetchScheduledStatuses()); }, [dispatch]);

  return (
    <Column>
      <ColumnHeader
        icon='clock-o'
        title={intl.formatMessage(messages.heading)}
        multiColumn={multiColumn}
        showBackButton
      />
      <div className='scrollable'>
        {!statuses || statuses.isEmpty() ? (
          <div className='empty-column-indicator'>{intl.formatMessage(messages.empty)}</div>
        ) : statuses.map(status => (
          <div key={status.get('id')} className='scheduled-status'>
            <div className='scheduled-status__content'>{status.getIn(['params', 'text'])}</div>
            <div className='scheduled-status__meta'>
              <time>{new Date(status.get('scheduled_at')).toLocaleString()}</time>
              <Button onClick={() => dispatch(cancelScheduledStatus(status.get('id')))}>
                {intl.formatMessage(messages.cancel)}
              </Button>
            </div>
          </div>
        ))}
      </div>
    </Column>
  );
};

export default ScheduledStatuses;