import { useCallback, useEffect, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import HistoryIcon from '@/material-icons/400-24px/history.svg?react';
import { addColumn, moveColumn, removeColumn } from 'mastodon/actions/columns';
import {
  expandScheduledStatuses,
  fetchScheduledStatuses,
} from 'mastodon/actions/scheduled_statuses';
import { Column } from 'mastodon/components/column';
import type { ColumnRef } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import ScrollableList from 'mastodon/components/scrollable_list';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { ScheduledStatusItem } from './components/scheduled_status_item';

const messages = defineMessages({
  heading: {
    id: 'column.scheduled_statuses',
    defaultMessage: 'Scheduled posts',
  },
});

const ScheduledStatuses: React.FC<{
  columnId?: string;
  multiColumn?: boolean;
}> = ({ columnId, multiColumn = false }) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const columnRef = useRef<ColumnRef>(null);
  const items = useAppSelector(
    (state) =>
      state.scheduled_statuses.get('items') as ImmutableList<
        ImmutableMap<string, unknown>
      >,
  );
  const isLoading = useAppSelector(
    (state) => state.scheduled_statuses.get('isLoading') as boolean,
  );
  const hasMore = useAppSelector(
    (state) => !!state.scheduled_statuses.get('next'),
  );

  useEffect(() => {
    dispatch(fetchScheduledStatuses());
  }, [dispatch]);

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('SCHEDULED_STATUSES', {}));
    }
  }, [columnId, dispatch]);

  const handleMove = useCallback(
    (dir: number) => {
      dispatch(moveColumn(columnId, dir));
    },
    [columnId, dispatch],
  );

  const handleHeaderClick = useCallback(() => {
    columnRef.current?.scrollTop();
  }, []);

  const handleLoadMore = useCallback(() => {
    dispatch(expandScheduledStatuses());
  }, [dispatch]);

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.scheduled_statuses'
      defaultMessage='No scheduled posts yet. Schedule a post to see it here.'
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={columnRef}
      label={intl.formatMessage(messages.heading)}
    >
      <ColumnHeader
        icon='history'
        iconComponent={HistoryIcon}
        title={intl.formatMessage(messages.heading)}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={!!columnId}
        multiColumn={multiColumn}
      />

      <ScrollableList
        scrollKey={`scheduled-statuses-${columnId ?? 'main'}`}
        trackScroll={!columnId}
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      >
        {items.map((scheduledStatus) => (
          <ScheduledStatusItem
            key={scheduledStatus.get('id') as string}
            scheduledStatus={scheduledStatus}
          />
        ))}
      </ScrollableList>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default ScheduledStatuses;
