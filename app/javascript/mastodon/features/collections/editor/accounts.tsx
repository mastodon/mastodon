import { useCallback, useId, useMemo, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import { showAlertForError } from 'mastodon/actions/alerts';
import { openModal } from 'mastodon/actions/modal';
import { apiFollowAccount } from 'mastodon/api/accounts';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { AccountListItem } from 'mastodon/components/account_list_item';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { EmptyState } from 'mastodon/components/empty_state';
import { FormStack, ComboboxField } from 'mastodon/components/form_fields';
import {
  Article,
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useSearchAccounts } from 'mastodon/hooks/useSearchAccounts';
import { me } from 'mastodon/initial_state';
import {
  addCollectionItem,
  getCollectionItemIds,
  removeCollectionItem,
  updateCollectionEditorField,
} from 'mastodon/reducers/slices/collections';
import { store, useAppDispatch, useAppSelector } from 'mastodon/store';

import classes from './styles.module.scss';
import { WizardStepTitle } from './wizard_step_title';

const MAX_ACCOUNT_COUNT = 25;

const AddedAccountItem: React.FC<{
  accountId: string;
  onRemove: (id: string) => void;
}> = ({ accountId, onRemove }) => {
  const handleRemoveAccount = useCallback(() => {
    onRemove(accountId);
  }, [accountId, onRemove]);

  const renderButton = useCallback(
    () => (
      <Button compact secondary onClick={handleRemoveAccount}>
        <FormattedMessage
          id='collections.remove_account'
          defaultMessage='Remove'
        />
      </Button>
    ),
    [handleRemoveAccount],
  );

  return <AccountListItem accountId={accountId} renderButton={renderButton} />;
};

interface SuggestionItem {
  id: string;
}

const SuggestedAccountItem: React.FC<SuggestionItem> = ({ id }) => {
  const account = useAccount(id);

  if (!account) return null;

  return (
    <>
      <Avatar account={account} />
      <DisplayName account={account} />
    </>
  );
};

const renderAccountItem = (item: SuggestionItem) => (
  <SuggestedAccountItem id={item.id} />
);

const getItemId = (item: SuggestionItem) => item.id;

export const CollectionAccounts: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const { id, items: collectionItems } = collection ?? {};
  const isEditMode = !!id;

  const addedAccountIds = useAppSelector(
    (state) => state.collections.editor.accountIds,
  );

  // In edit mode, we're bypassing state and just return collection items directly,
  // since they're edited "live", saving after each addition/deletion
  const accountIds = useMemo(
    () =>
      isEditMode ? getCollectionItemIds(collectionItems) : addedAccountIds,
    [isEditMode, collectionItems, addedAccountIds],
  );

  const [searchValue, setSearchValue] = useState('');

  const hasAccounts = accountIds.length > 0;
  const hasMaxAccounts = accountIds.length === MAX_ACCOUNT_COUNT;

  const {
    accounts: suggestedAccounts,
    isLoading: isLoadingSuggestions,
    searchAccounts,
    resetAccounts,
  } = useSearchAccounts({
    withRelationships: true,
    filterResults: (account) =>
      !accountIds.includes(account.id) &&
      // Only suggest accounts who allow being featured/recommended
      account.feature_approval.current_user === 'automatic',
  });

  const suggestedItems = suggestedAccounts.map(({ id }) => ({
    id,
    isDisabled: accountIds.includes(id),
  }));

  const handleSearchValueChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      setSearchValue(e.target.value);
      searchAccounts(e.target.value);
    },
    [searchAccounts],
  );

  const handleSearchKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === 'Enter') {
        e.preventDefault();
      }
    },
    [],
  );

  const relationships = useAppSelector((state) => state.relationships);

  const confirmFollowStatus = useCallback(
    (accountId: string, onFollowing: () => void) => {
      const relationship = relationships.get(accountId);

      if (!relationship) {
        return;
      }

      if (
        accountId === me ||
        relationship.following ||
        relationship.requested
      ) {
        onFollowing();
      } else {
        dispatch(
          openModal({
            modalType: 'CONFIRM_FOLLOW_TO_COLLECTION',
            modalProps: {
              accountId,
              onConfirm: () => {
                apiFollowAccount(accountId)
                  .then(onFollowing)
                  .catch((err: unknown) => {
                    store.dispatch(showAlertForError(err));
                  });
              },
            },
          }),
        );
      }
    },
    [dispatch, relationships],
  );

  const removeAccountItem = useCallback(
    (accountId: string) => {
      dispatch(
        updateCollectionEditorField({
          field: 'accountIds',
          value: accountIds.filter((id) => id !== accountId),
        }),
      );
    },
    [accountIds, dispatch],
  );

  const addAccountItem = useCallback(
    (item: SuggestionItem) => {
      confirmFollowStatus(item.id, () => {
        dispatch(
          updateCollectionEditorField({
            field: 'accountIds',
            value: [...accountIds, item.id],
          }),
        );
      });
    },
    [accountIds, confirmFollowStatus, dispatch],
  );

  const instantRemoveAccountItem = useCallback(
    (accountId: string) => {
      const itemId = collectionItems?.find(
        (item) => item.account_id === accountId,
      )?.id;
      if (itemId && id) {
        if (
          window.confirm(
            intl.formatMessage({
              id: 'collections.confirm_account_removal',
              defaultMessage:
                'Are you sure you want to remove this account from this collection?',
            }),
          )
        ) {
          void dispatch(removeCollectionItem({ collectionId: id, itemId }));
        }
      }
    },
    [collectionItems, dispatch, id, intl],
  );

  const instantAddAccountItem = useCallback(
    (item: SuggestionItem) => {
      confirmFollowStatus(item.id, () => {
        if (id) {
          void dispatch(
            addCollectionItem({ collectionId: id, accountId: item.id }),
          );
        }
      });
    },
    [confirmFollowStatus, dispatch, id],
  );

  const handleRemoveAccountItem = useCallback(
    (accountId: string) => {
      if (isEditMode) {
        instantRemoveAccountItem(accountId);
      } else {
        removeAccountItem(accountId);
      }
    },
    [isEditMode, instantRemoveAccountItem, removeAccountItem],
  );

  const handleSelectItem = useCallback(
    (item: SuggestionItem) => {
      if (isEditMode) {
        instantAddAccountItem(item);
      } else {
        addAccountItem(item);
      }

      setSearchValue('');
      resetAccounts();
    },
    [addAccountItem, instantAddAccountItem, isEditMode, resetAccounts],
  );

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();

      if (!id) {
        history.push(`/collections/new/details`, {
          account_ids: accountIds,
        });
      }
    },
    [id, history, accountIds],
  );

  const inputId = useId();
  const AccountsHeadingElement = id ? 'h2' : 'h3';

  return (
    <form onSubmit={handleSubmit} className={classes.form}>
      <FormStack className={classes.formFieldStack}>
        <header className={classes.header}>
          {!id && (
            <WizardStepTitle
              step={1}
              title={
                <FormattedMessage
                  id='collections.create.accounts_title'
                  defaultMessage='Who will you feature in this collection?'
                />
              }
            />
          )}
          <ComboboxField
            id={inputId}
            label={intl.formatMessage({
              id: 'collections.search_accounts_label',
              defaultMessage: 'Search for an account to add',
            })}
            value={hasMaxAccounts ? '' : searchValue}
            onChange={handleSearchValueChange}
            onKeyDown={handleSearchKeyDown}
            disabled={hasMaxAccounts}
            isLoading={isLoadingSuggestions}
            items={suggestedItems}
            getItemId={getItemId}
            renderItem={renderAccountItem}
            onSelectItem={handleSelectItem}
            status={
              hasMaxAccounts
                ? {
                    variant: 'warning',
                    message: intl.formatMessage({
                      id: 'collections.search_accounts_max_reached',
                      defaultMessage:
                        'You have added the maximum number of accounts',
                    }),
                  }
                : null
            }
          />
        </header>

        <div>
          {hasAccounts && (
            <AccountsHeadingElement className={classes.listHeading}>
              <FormattedMessage
                id='collections.hints.accounts_counter'
                defaultMessage='{count}/{max} accounts'
                values={{ count: accountIds.length, max: MAX_ACCOUNT_COUNT }}
              />
            </AccountsHeadingElement>
          )}

          <Scrollable className={classes.scrollableWrapper}>
            <ItemList
              emptyMessage={
                <EmptyState
                  title={
                    <FormattedMessage
                      id='collections.accounts.empty_editor_title'
                      defaultMessage='No one is in this collection yet'
                    />
                  }
                  message={
                    <FormattedMessage
                      id='collections.accounts.empty_description'
                      defaultMessage='Add up to {count} accounts'
                      values={{
                        count: MAX_ACCOUNT_COUNT,
                      }}
                    />
                  }
                />
              }
            >
              {accountIds.map((accountId, index) => (
                <Article
                  key={accountId}
                  aria-posinset={index}
                  aria-setsize={accountIds.length}
                >
                  <AddedAccountItem
                    accountId={accountId}
                    onRemove={handleRemoveAccountItem}
                  />
                </Article>
              ))}
            </ItemList>
          </Scrollable>
        </div>
      </FormStack>
      {!isEditMode && hasAccounts && (
        <div className={classes.stickyFooter}>
          <Button type='submit'>
            {id ? (
              <FormattedMessage id='lists.save' defaultMessage='Save' />
            ) : (
              <FormattedMessage
                id='collections.continue'
                defaultMessage='Continue'
              />
            )}
          </Button>
        </div>
      )}
    </form>
  );
};
