import { useCallback, useEffect } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { List as ImmutableList } from 'immutable';

import RefreshIcon from '@/material-icons/400-24px/refresh.svg?react';
import { fetchQuotes } from 'mastodon/actions/interactions_typed';
import { ColumnHeader } from 'mastodon/components/column_header';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import StatusList from 'mastodon/components/status_list';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import Column from '../ui/components/column';

const messages = defineMessages({
  refresh: { id: 'refresh', defaultMessage: 'Refresh' },
});

const emptyList = ImmutableList();

export const Quotes: React.FC<{
  multiColumn?: boolean;
  params?: { statusId: string };
}> = ({ multiColumn, params }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const statusId = params?.statusId;

  const isCorrectStatusId: boolean = useAppSelector(
    (state) => state.status_lists.getIn(['quotes', 'statusId']) === statusId,
  );
  const statusIds = useAppSelector((state) =>
    state.status_lists.getIn(['quotes', 'items'], emptyList),
  );
  const nextUrl = useAppSelector(
    (state) =>
      state.status_lists.getIn(['quotes', 'next']) as string | undefined,
  );
  const isLoading = useAppSelector((state) =>
    state.status_lists.getIn(['quotes', 'isLoading'], true),
  );
  const hasMore = !!nextUrl;

  useEffect(() => {
    if (statusId) void dispatch(fetchQuotes({ statusId }));
  }, [dispatch, statusId]);

  const handleLoadMore = useCallback(() => {
    if (statusId && isCorrectStatusId && nextUrl)
      void dispatch(fetchQuotes({ statusId, next: nextUrl }));
  }, [dispatch, statusId, isCorrectStatusId, nextUrl]);

  const handleRefresh = useCallback(() => {
    if (statusId) void dispatch(fetchQuotes({ statusId }));
  }, [dispatch, statusId]);

  if (!statusIds || !isCorrectStatusId) {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  }

  const emptyMessage = (
    <FormattedMessage
      id='status.quotes.empty'
      defaultMessage='No one has quoted this post yet. When someone does, it will show up here.'
    />
  );

  return (
    <Column bindToDocument={!multiColumn}>
      <ColumnHeader
        showBackButton
        multiColumn={multiColumn}
        extraButton={
          <button
            type='button'
            className='column-header__button'
            title={intl.formatMessage(messages.refresh)}
            aria-label={intl.formatMessage(messages.refresh)}
            onClick={handleRefresh}
          >
            <Icon id='refresh' icon={RefreshIcon} />
          </button>
        }
      />

      <StatusList
        scrollKey='quotes_timeline'
        statusIds={statusIds}
        onLoadMore={handleLoadMore}
        hasMore={hasMore}
        isLoading={isLoading}
        emptyMessage={emptyMessage}
        bindToDocument={!multiColumn}
      />

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Quotes;
