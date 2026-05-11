import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type {
  Map as ImmutableMap,
  OrderedMap as ImmutableOrderedMap,
} from 'immutable';

import { Helmet } from '@unhead/react/helmet';

import HourglassIcon from '@/material-icons/400-24px/hourglass.svg?react';
import {
  cancelScheduledStatus,
  expandScheduledStatuses,
  fetchScheduledStatuses,
  updateScheduledStatus,
} from 'mastodon/actions/scheduled_statuses';
import { Button } from 'mastodon/components/button';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import { useAppDispatch, useAppSelector } from 'mastodon/store';
import {
  dateTimeLocalToISOString,
  isoStringToDateTimeLocal,
  minScheduledDateTimeLocal,
} from 'mastodon/utils/scheduled_statuses';

const messages = defineMessages({
  heading: {
    id: 'column.scheduled_statuses',
    defaultMessage: 'Scheduled posts',
  },
  scheduledFor: {
    id: 'scheduled_statuses.scheduled_for',
    defaultMessage: 'Scheduled for {date}',
  },
  save: { id: 'scheduled_statuses.save', defaultMessage: 'Save' },
  cancel: { id: 'scheduled_statuses.cancel', defaultMessage: 'Cancel' },
  cancelConfirm: {
    id: 'scheduled_statuses.cancel_confirm',
    defaultMessage: 'Cancel this scheduled post?',
  },
  noText: { id: 'scheduled_statuses.no_text', defaultMessage: 'No text' },
});

type ScheduledStatus = ImmutableMap<string, unknown>;

const ScheduledStatusItem: React.FC<{
  status: ScheduledStatus;
  isLoading: boolean;
}> = ({ status, isLoading }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const id = status.get('id') as string;
  const scheduledAt = status.get('scheduled_at') as string;
  const text = status.getIn(['params', 'text']) as string | undefined;
  const spoilerText = status.getIn(['params', 'spoiler_text']) as
    | string
    | undefined;
  const [scheduledAtValue, setScheduledAtValue] = useState(
    isoStringToDateTimeLocal(scheduledAt),
  );

  useEffect(() => {
    setScheduledAtValue(isoStringToDateTimeLocal(scheduledAt));
  }, [scheduledAt]);

  const formattedDate = intl.formatDate(new Date(scheduledAt), {
    dateStyle: 'medium',
    timeStyle: 'short',
  });

  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setScheduledAtValue(event.target.value);
    },
    [],
  );

  const handleSave = useCallback(() => {
    const nextScheduledAt = dateTimeLocalToISOString(scheduledAtValue);

    if (nextScheduledAt) {
      dispatch(updateScheduledStatus(id, nextScheduledAt));
    }
  }, [dispatch, id, scheduledAtValue]);

  const handleCancel = useCallback(() => {
    if (window.confirm(intl.formatMessage(messages.cancelConfirm))) {
      dispatch(cancelScheduledStatus(id));
    }
  }, [dispatch, id, intl]);

  return (
    <article className='scheduled-status'>
      <div className='scheduled-status__body'>
        {spoilerText && (
          <div className='scheduled-status__spoiler'>{spoilerText}</div>
        )}

        <div className='scheduled-status__content'>
          {text ?? intl.formatMessage(messages.noText)}
        </div>

        <div className='scheduled-status__meta'>
          {intl.formatMessage(messages.scheduledFor, {
            date: formattedDate,
          })}
        </div>
      </div>

      <div className='scheduled-status__actions'>
        <input
          type='datetime-local'
          min={minScheduledDateTimeLocal()}
          value={scheduledAtValue}
          onChange={handleChange}
          disabled={isLoading}
        />
        <Button
          compact
          secondary
          disabled={
            isLoading ||
            dateTimeLocalToISOString(scheduledAtValue) === scheduledAt
          }
          onClick={handleSave}
        >
          {intl.formatMessage(messages.save)}
        </Button>
        <Button compact dangerous disabled={isLoading} onClick={handleCancel}>
          {intl.formatMessage(messages.cancel)}
        </Button>
      </div>
    </article>
  );
};

const ScheduledStatuses: React.FC<{ multiColumn: boolean }> = ({
  multiColumn,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const columnRef = useRef<ColumnRef>(null);
  const scheduledStatusesState = useAppSelector(
    (state): unknown => state.scheduled_statuses,
  ) as ImmutableMap<string, unknown>;
  const statuses = scheduledStatusesState.get('items') as ImmutableOrderedMap<
    string,
    ScheduledStatus
  >;
  const isLoading = scheduledStatusesState.get('isLoading') as boolean;
  const hasMore = !!scheduledStatusesState.get('next');

  useEffect(() => {
    dispatch(fetchScheduledStatuses());
  }, [dispatch]);

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const handleLoadMore = useCallback(() => {
    dispatch(expandScheduledStatuses());
  }, [dispatch]);

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.scheduled_statuses'
      defaultMessage='You do not have any scheduled posts.'
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        icon='hourglass'
        iconComponent={HourglassIcon}
        title={intl.formatMessage(messages.heading)}
        onClick={handleHeaderClick}
        multiColumn={multiColumn}
        showBackButton
      />

      <ScrollableList
        scrollKey='scheduled_statuses'
        onLoadMore={handleLoadMore}
        hasMore={hasMore}
        isLoading={isLoading}
        showLoading={isLoading && statuses.isEmpty()}
        emptyMessage={emptyMessage}
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
      >
        {statuses
          .valueSeq()
          .map((status) => (
            <ScheduledStatusItem
              key={status.get('id') as string}
              status={status}
              isLoading={isLoading}
            />
          ))
          .toArray()}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default ScheduledStatuses;
