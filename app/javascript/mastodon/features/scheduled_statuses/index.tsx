import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { Helmet } from '@unhead/react/helmet';

import {
  addColumn,
  moveColumn,
  removeColumn,
} from '@/mastodon/actions/columns';
import {
  expandScheduledStatuses,
  fetchScheduledStatuses,
} from '@/mastodon/actions/scheduled_statuses';
import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import {
  ColumnHeader,
  ColumnSettingsMenu,
} from '@/mastodon/components/column_header';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';
import ScrollableList from '@/mastodon/components/scrollable_list';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import HistoryIcon from '@/material-icons/400-24px/history.svg?react';

import { ScheduledStatusItem } from './components/scheduled_status_item';

const messages = defineMessages({
  heading: {
    id: 'column.scheduled_statuses',
    defaultMessage: 'Scheduled posts',
  },
});

interface Props {
  columnId?: string;
  multiColumn?: boolean;
}

const ScheduledStatuses: React.FC<Props> = ({
  columnId,
  multiColumn = false,
}) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
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

  const pinned = !!columnId;

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('SCHEDULED_STATUSES', {}));
    }
  }, [columnId, dispatch]);

  const handleMove = useCallback(
    (dir: number) => {
      if (columnId) {
        dispatch(moveColumn(columnId, dir));
      }
    },
    [columnId, dispatch],
  );

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
      label={intl.formatMessage(messages.heading)}
    >
      {isRedesignEnabled() ? (
        <ColumnHeader
          title={intl.formatMessage(messages.heading)}
          withBackButton={multiColumn && !pinned && 'auto'}
          extraButtons={
            multiColumn && (
              <ColumnSettingsMenu
                labelPrefix={intl.formatMessage(messages.heading)}
              >
                <MultiColumnMenuItems
                  pinned={pinned}
                  onPin={handlePin}
                  onMove={handleMove}
                />
              </ColumnSettingsMenu>
            )
          }
        />
      ) : (
        <LegacyColumnHeader
          icon='history'
          iconComponent={HistoryIcon}
          title={intl.formatMessage(messages.heading)}
          onPin={handlePin}
          onMove={handleMove}
          pinned={pinned}
          multiColumn={multiColumn}
          scrollTopOnClick
        />
      )}

      <ScrollableList
        scrollKey={`scheduled_statuses-${columnId ?? 'main'}`}
        trackScroll={!pinned}
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

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default ScheduledStatuses;
