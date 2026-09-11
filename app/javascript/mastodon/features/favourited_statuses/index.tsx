import { useEffect, useCallback } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import {
  ColumnHeader,
  ColumnSettingsMenu,
} from '@/mastodon/components/column_header';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import StarIcon from '@/material-icons/400-24px/star-fill.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import {
  fetchFavouritedStatuses,
  expandFavouritedStatuses,
} from 'mastodon/actions/favourites';
import StatusList from 'mastodon/components/status_list';
import { getStatusList } from 'mastodon/selectors';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favorites' },
  heading_redesign: {
    id: 'navigation_bar.liked_posts',
    defaultMessage: 'Liked Posts',
  },
});

const Favourites: React.FC<{ columnId: string; multiColumn: boolean }> = ({
  columnId,
  multiColumn,
}) => {
  const dispatch = useAppDispatch();
  const intl = useIntl();
  const statusIds = useAppSelector((state) =>
    getStatusList(state, 'favourites'),
  );
  const isLoading = useAppSelector(
    (state) =>
      state.status_lists.getIn(['favourites', 'isLoading'], true) as boolean,
  );
  const hasMore = useAppSelector(
    (state) => !!state.status_lists.getIn(['favourites', 'next']),
  );

  useEffect(() => {
    dispatch(fetchFavouritedStatuses());
  }, [dispatch]);

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('FAVOURITES', {}));
    }
  }, [dispatch, columnId]);

  const handleMove = useCallback(
    (dir: number) => {
      dispatch(moveColumn(columnId, dir));
    },
    [dispatch, columnId],
  );

  const handleLoadMore = useCallback(() => {
    dispatch(expandFavouritedStatuses());
  }, [dispatch]);

  const pinned = !!columnId;

  const emptyMessage = (
    <FormattedMessage
      id='empty_column.favourited_statuses'
      defaultMessage="You don't have any favorite posts yet. When you favorite one, it will show up here."
    />
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.heading)}
    >
      {isRedesignEnabled() ? (
        <ColumnHeader
          title={intl.formatMessage(messages.heading_redesign)}
          withBackButton={multiColumn && !pinned && 'auto'}
          extraButtons={
            multiColumn && (
              <ColumnSettingsMenu
                labelPrefix={intl.formatMessage(messages.heading_redesign)}
              >
                <MultiColumnMenuItems
                  onPin={handlePin}
                  onMove={handleMove}
                  pinned={pinned}
                />
              </ColumnSettingsMenu>
            )
          }
        />
      ) : (
        <LegacyColumnHeader
          icon='star'
          iconComponent={StarIcon}
          title={intl.formatMessage(messages.heading)}
          onPin={handlePin}
          onMove={handleMove}
          pinned={pinned}
          multiColumn={multiColumn}
          scrollTopOnClick
        />
      )}

      <StatusList
        trackScroll={!pinned}
        statusIds={statusIds}
        scrollKey={`favourited_statuses-${columnId}`}
        hasMore={hasMore}
        isLoading={isLoading}
        onLoadMore={handleLoadMore}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
        timelineId='favourites'
      />

      <Helmet>
        <title>{intl.formatMessage(messages.heading)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Favourites;
