import type { ChangeEventHandler } from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { List as ImmutableList } from 'immutable';

import PeopleIcon from '@/material-icons/400-24px/group.svg?react';
import {
  addColumn,
  removeColumn,
  moveColumn,
  changeColumnParams,
} from 'mastodon/actions/columns';
import { fetchDirectory, expandDirectory } from 'mastodon/actions/directory';
import Column from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { LoadMore } from 'mastodon/components/load_more';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { RadioButton } from 'mastodon/components/radio_button';
import ScrollContainer from 'mastodon/containers/scroll_container';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { AccountCard } from './components/account_card';

const messages = defineMessages({
  title: { id: 'column.directory', defaultMessage: 'Browse profiles' },
  recentlyActive: {
    id: 'directory.recently_active',
    defaultMessage: 'Recently active',
  },
  newArrivals: { id: 'directory.new_arrivals', defaultMessage: 'New arrivals' },
  local: { id: 'directory.local', defaultMessage: 'From {domain} only' },
  federated: {
    id: 'directory.federated',
    defaultMessage: 'From known fediverse',
  },
});

export const Directory: React.FC<{
  columnId?: string;
  multiColumn?: boolean;
  params?: { order: string; local?: boolean };
}> = ({ columnId, multiColumn, params }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const [state, setState] = useState<{
    order: string | null;
    local: boolean | null;
  }>({
    order: null,
    local: null,
  });

  const column = useRef<Column>(null);

  const order = state.order ?? params?.order ?? 'active';
  const local = state.local ?? params?.local ?? false;

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('DIRECTORY', { order, local }));
    }
  }, [dispatch, columnId, order, local]);

  const domain = useAppSelector((s) => s.meta.get('domain') as string);
  const accountIds = useAppSelector(
    (state) =>
      state.user_lists.getIn(
        ['directory', 'items'],
        ImmutableList(),
      ) as ImmutableList<string>,
  );
  const isLoading = useAppSelector(
    (state) =>
      state.user_lists.getIn(['directory', 'isLoading'], true) as boolean,
  );

  useEffect(() => {
    void dispatch(fetchDirectory({ order, local }));
  }, [dispatch, order, local]);

  const handleMove = useCallback(
    (dir: number) => {
      dispatch(moveColumn(columnId, dir));
    },
    [dispatch, columnId],
  );

  const handleHeaderClick = useCallback(() => {
    column.current?.scrollTop();
  }, []);

  const handleChangeOrder = useCallback<ChangeEventHandler<HTMLInputElement>>(
    (e) => {
      if (columnId) {
        dispatch(changeColumnParams(columnId, ['order'], e.target.value));
      } else {
        setState((s) => ({ order: e.target.value, local: s.local }));
      }
    },
    [dispatch, columnId],
  );

  const handleChangeLocal = useCallback<ChangeEventHandler<HTMLInputElement>>(
    (e) => {
      if (columnId) {
        dispatch(
          changeColumnParams(columnId, ['local'], e.target.value === '1'),
        );
      } else {
        setState((s) => ({ local: e.target.value === '1', order: s.order }));
      }
    },
    [dispatch, columnId],
  );

  const handleLoadMore = useCallback(() => {
    void dispatch(expandDirectory({ order, local }));
  }, [dispatch, order, local]);

  const pinned = !!columnId;

  const scrollableArea = (
    <div className='scrollable'>
      <div className='filter-form'>
        <div className='filter-form__column' role='group'>
          <RadioButton
            name='order'
            value='active'
            label={intl.formatMessage(messages.recentlyActive)}
            checked={order === 'active'}
            onChange={handleChangeOrder}
          />
          <RadioButton
            name='order'
            value='new'
            label={intl.formatMessage(messages.newArrivals)}
            checked={order === 'new'}
            onChange={handleChangeOrder}
          />
        </div>

        <div className='filter-form__column' role='group'>
          <RadioButton
            name='local'
            value='1'
            label={intl.formatMessage(messages.local, { domain })}
            checked={local}
            onChange={handleChangeLocal}
          />
          <RadioButton
            name='local'
            value='0'
            label={intl.formatMessage(messages.federated)}
            checked={!local}
            onChange={handleChangeLocal}
          />
        </div>
      </div>

      <div className='directory__list'>
        {isLoading ? (
          <LoadingIndicator />
        ) : (
          accountIds.map((accountId) => (
            <AccountCard accountId={accountId} key={accountId} />
          ))
        )}
      </div>

      <LoadMore onClick={handleLoadMore} visible={!isLoading} />
    </div>
  );

  return (
    <Column
      bindToDocument={!multiColumn}
      ref={column}
      label={intl.formatMessage(messages.title)}
    >
      <ColumnHeader
        icon='address-book-o'
        iconComponent={PeopleIcon}
        title={intl.formatMessage(messages.title)}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={pinned}
        multiColumn={multiColumn}
      />

      {multiColumn && !pinned ? (
        // @ts-expect-error ScrollContainer is not properly typed yet
        <ScrollContainer scrollKey='directory'>
          {scrollableArea}
        </ScrollContainer>
      ) : (
        scrollableArea
      )}

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export -- Needed because this is called as an async components
export default Directory;
