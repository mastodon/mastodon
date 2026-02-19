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
import { useIdentity } from 'mastodon/identity_context';
import { domain } from 'mastodon/initial_state';
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

  const { accountId: me } = useIdentity();

  const isCorrectStatusId: boolean = useAppSelector(
    (state) => state.status_lists.getIn(['quotes', 'statusId']) === statusId,
  );
  const quotedAccountId = useAppSelector(
    (state) =>
      state.statuses.getIn([statusId, 'account']) as string | undefined,
  );
  const quotedAccount = useAppSelector((state) =>
    quotedAccountId ? state.accounts.get(quotedAccountId) : undefined,
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

  let prependMessage;

  if (me === quotedAccountId) {
    prependMessage = null;
  } else if (quotedAccount?.username === quotedAccount?.acct) {
    // Local account, we know this to be exhaustive
    prependMessage = (
      <div className='follow_requests-unlocked_explanation'>
        <FormattedMessage
          id='status.quotes.local_other_disclaimer'
          defaultMessage='Quotes rejected by the author will not be shown.'
        />
      </div>
    );
  } else {
    prependMessage = (
      <div className='follow_requests-unlocked_explanation'>
        <FormattedMessage
          id='status.quotes.remote_other_disclaimer'
          defaultMessage='Only quotes from {domain} are guaranteed to be shown here. Quotes rejected by the author will not be shown.'
          values={{ domain: <strong>{domain}</strong> }}
        />
      </div>
    );
  }

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
        prepend={prependMessage}
      />

      <Helmet>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Quotes;
