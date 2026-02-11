import { useCallback, useState, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { useParams, Link } from 'react-router-dom';

import ListAltIcon from '@/material-icons/400-24px/list_alt.svg?react';
import SquigglyArrow from '@/svg-icons/squiggly_arrow.svg?react';
import { fetchRelationships } from 'mastodon/actions/accounts';
import { showAlertForError } from 'mastodon/actions/alerts';
import { importFetchedAccounts } from 'mastodon/actions/importer';
import { fetchList } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import { apiFollowAccount } from 'mastodon/api/accounts';
import {
  apiGetAccounts,
  apiAddAccountToList,
  apiRemoveAccountFromList,
} from 'mastodon/api/lists';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { ColumnSearchHeader } from 'mastodon/components/column_search_header';
import { FollowersCounter } from 'mastodon/components/counters';
import { DisplayName } from 'mastodon/components/display_name';
import ScrollableList from 'mastodon/components/scrollable_list';
import { ShortNumber } from 'mastodon/components/short_number';
import { VerifiedBadge } from 'mastodon/components/verified_badge';
import { me } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import { useSearchAccounts } from './use_search_accounts';

export const messages = defineMessages({
  manageMembers: {
    id: 'column.list_members',
    defaultMessage: 'Manage list members',
  },
  placeholder: {
    id: 'lists.search',
    defaultMessage: 'Search',
  },
  enterSearch: { id: 'lists.add_to_list', defaultMessage: 'Add to list' },
  add: { id: 'lists.add_member', defaultMessage: 'Add' },
  remove: { id: 'lists.remove_member', defaultMessage: 'Remove' },
  back: { id: 'column_back_button.label', defaultMessage: 'Back' },
});

type Mode = 'remove' | 'add';

const AccountItem: React.FC<{
  accountId: string;
  listId: string;
  partOfList: boolean;
  onToggle: (accountId: string) => void;
}> = ({ accountId, listId, partOfList, onToggle }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const relationship = useAppSelector((state) =>
    accountId ? state.relationships.get(accountId) : undefined,
  );
  const following =
    accountId === me || relationship?.following || relationship?.requested;

  useEffect(() => {
    if (accountId) {
      dispatch(fetchRelationships([accountId]));
    }
  }, [dispatch, accountId]);

  const handleClick = useCallback(() => {
    if (partOfList) {
      void apiRemoveAccountFromList(listId, accountId);
      onToggle(accountId);
    } else {
      if (following) {
        void apiAddAccountToList(listId, accountId);
        onToggle(accountId);
      } else {
        dispatch(
          openModal({
            modalType: 'CONFIRM_FOLLOW_TO_LIST',
            modalProps: {
              accountId,
              onConfirm: () => {
                apiFollowAccount(accountId)
                  .then(() => apiAddAccountToList(listId, accountId))
                  .then(() => {
                    onToggle(accountId);
                    return '';
                  })
                  .catch((err: unknown) => {
                    dispatch(showAlertForError(err));
                  });
              },
            },
          }),
        );
      }
    }
  }, [dispatch, accountId, following, listId, partOfList, onToggle]);

  if (!account) {
    return null;
  }

  const firstVerifiedField = account.fields.find((item) => !!item.verified_at);

  return (
    <div className='account'>
      <div className='account__wrapper'>
        <Link
          key={account.id}
          className='account__display-name'
          title={account.acct}
          to={`/@${account.acct}`}
          data-hover-card-account={account.id}
        >
          <div className='account__avatar-wrapper'>
            <Avatar account={account} size={36} />
          </div>

          <div className='account__contents'>
            <DisplayName account={account} />

            <div className='account__details'>
              <ShortNumber
                value={account.followers_count}
                renderer={FollowersCounter}
              />{' '}
              {firstVerifiedField && (
                <VerifiedBadge link={firstVerifiedField.value} />
              )}
            </div>
          </div>
        </Link>

        <div className='account__relationship'>
          <Button
            text={intl.formatMessage(
              partOfList ? messages.remove : messages.add,
            )}
            secondary={partOfList}
            onClick={handleClick}
          />
        </div>
      </div>
    </div>
  );
};

const ListMembers: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const dispatch = useAppDispatch();
  const { id } = useParams<{ id: string }>();
  const intl = useIntl();

  const [searching, setSearching] = useState(false);
  const [accountIds, setAccountIds] = useState<string[]>([]);
  const [loading, setLoading] = useState(!!id);
  const [mode, setMode] = useState<Mode>('remove');

  const {
    accountIds: searchAccountIds,
    isLoading: loadingSearchResults,
    searchAccounts: handleSearch,
  } = useSearchAccounts({
    resetOnInputClear: false,
    onSettled: (value) => {
      if (value.trim().length === 0) {
        setSearching(false);
      } else {
        setSearching(true);
      }
    },
  });

  useEffect(() => {
    if (id) {
      dispatch(fetchList(id));

      void apiGetAccounts(id)
        .then((data) => {
          dispatch(importFetchedAccounts(data));
          setAccountIds(data.map((a) => a.id));
          setLoading(false);
          return '';
        })
        .catch(() => {
          setLoading(false);
        });
    }
  }, [dispatch, id]);

  const handleSearchClick = useCallback(() => {
    setMode('add');
  }, [setMode]);

  const handleDismissSearchClick = useCallback(() => {
    setMode('remove');
    setSearching(false);
  }, [setMode]);

  const handleAccountToggle = useCallback(
    (accountId: string) => {
      const partOfList = accountIds.includes(accountId);

      if (partOfList) {
        setAccountIds(accountIds.filter((id) => id !== accountId));
      } else {
        setAccountIds([accountId, ...accountIds]);
      }
    },
    [accountIds, setAccountIds],
  );

  let displayedAccountIds: string[];

  if (mode === 'add' && searching) {
    displayedAccountIds = searchAccountIds;
  } else {
    displayedAccountIds = accountIds;
  }

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.manageMembers)}
    >
      <ColumnHeader
        title={intl.formatMessage(messages.manageMembers)}
        icon='list-ul'
        iconComponent={ListAltIcon}
        multiColumn={multiColumn}
        showBackButton
      />

      <ColumnSearchHeader
        placeholder={intl.formatMessage(messages.placeholder)}
        onBack={handleDismissSearchClick}
        onSubmit={handleSearch}
        onActivate={handleSearchClick}
        active={mode === 'add'}
      />

      <ScrollableList
        scrollKey='list_members'
        trackScroll={!multiColumn}
        bindToDocument={!multiColumn}
        isLoading={loading || loadingSearchResults}
        showLoading={loading && displayedAccountIds.length === 0}
        hasMore={false}
        footer={
          <>
            {displayedAccountIds.length > 0 && <div className='spacer' />}

            <div className='column-footer'>
              <Link to={`/lists/${id}`} className='button button--block'>
                <FormattedMessage id='lists.done' defaultMessage='Done' />
              </Link>
            </div>
          </>
        }
        emptyMessage={
          mode === 'remove' ? (
            <>
              <span>
                <FormattedMessage
                  id='lists.no_members_yet'
                  defaultMessage='No members yet.'
                />
                <br />
                <FormattedMessage
                  id='lists.find_users_to_add'
                  defaultMessage='Find users to add'
                />
              </span>

              <SquigglyArrow className='empty-column-indicator__arrow' />
            </>
          ) : (
            <FormattedMessage
              id='lists.no_results_found'
              defaultMessage='No results found.'
            />
          )
        }
      >
        {displayedAccountIds.map((accountId) => (
          <AccountItem
            key={accountId}
            accountId={accountId}
            listId={id}
            partOfList={
              displayedAccountIds === accountIds ||
              accountIds.includes(accountId)
            }
            onToggle={handleAccountToggle}
          />
        ))}
      </ScrollableList>

      <Helmet>
        <title>{intl.formatMessage(messages.manageMembers)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default ListMembers;
