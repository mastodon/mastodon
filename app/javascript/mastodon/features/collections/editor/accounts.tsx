import { useCallback, useId, useMemo, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import CancelIcon from '@/material-icons/400-24px/cancel.svg?react';
import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import { showAlertForError } from 'mastodon/actions/alerts';
import { openModal } from 'mastodon/actions/modal';
import { apiFollowAccount } from 'mastodon/api/accounts';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Account } from 'mastodon/components/account';
import { Avatar } from 'mastodon/components/avatar';
import { Badge } from 'mastodon/components/badge';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { EmptyState } from 'mastodon/components/empty_state';
import { FormStack, Combobox } from 'mastodon/components/form_fields';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
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
import { WizardStepHeader } from './wizard_step_header';

const MAX_ACCOUNT_COUNT = 25;

function isOlderThanAWeek(date?: string): boolean {
  if (!date) return false;

  const targetDate = new Date(date);
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  return targetDate < sevenDaysAgo;
}

const AddedAccountItem: React.FC<{
  accountId: string;
  onRemove: (id: string) => void;
}> = ({ accountId, onRemove }) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  const handleRemoveAccount = useCallback(() => {
    onRemove(accountId);
  }, [accountId, onRemove]);

  const lastStatusAt = account?.last_status_at;

  const lastPostHint = useMemo(
    () =>
      (!lastStatusAt || isOlderThanAWeek(lastStatusAt)) && (
        <Badge
          label={
            <FormattedMessage
              id='collections.old_last_post_note'
              defaultMessage='Last posted over a week ago'
            />
          }
          icon={<WarningIcon />}
          className={classes.accountBadge}
        />
      ),
    [lastStatusAt],
  );

  return (
    <Account
      minimal
      key={accountId}
      id={accountId}
      extraAccountInfo={lastPostHint}
    >
      <IconButton
        title={intl.formatMessage({
          id: 'collections.remove_account',
          defaultMessage: 'Remove this account',
        })}
        icon='remove'
        iconComponent={CancelIcon}
        onClick={handleRemoveAccount}
      />
    </Account>
  );
};

interface SuggestionItem {
  id: string;
  isSelected: boolean;
}

const SuggestedAccountItem: React.FC<SuggestionItem> = ({ id, isSelected }) => {
  const account = useAccount(id);

  if (!account) return null;

  return (
    <>
      <Avatar account={account} />
      <DisplayName account={account} />
      {isSelected && (
        <Icon
          id='checked'
          icon={CheckIcon}
          className={classes.selectedSuggestionIcon}
        />
      )}
    </>
  );
};

const renderAccountItem = (item: SuggestionItem) => (
  <SuggestedAccountItem id={item.id} isSelected={item.isSelected} />
);

const getItemId = (item: SuggestionItem) => item.id;
const getIsItemSelected = (item: SuggestionItem) => item.isSelected;

export const CollectionAccounts: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();

  const { id, items } = collection ?? {};
  const isEditMode = !!id;
  const collectionItems = items;

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

  const hasMaxAccounts = accountIds.length === MAX_ACCOUNT_COUNT;

  const {
    accountIds: suggestedAccountIds,
    isLoading: isLoadingSuggestions,
    searchAccounts,
  } = useSearchAccounts({
    withRelationships: true,
    filterResults: (account) =>
      // Only suggest accounts who allow being featured/recommended
      account.feature_approval.current_user === 'automatic',
  });

  const suggestedItems = suggestedAccountIds.map((id) => ({
    id,
    isSelected: accountIds.includes(id),
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
    (accountId: string) => {
      confirmFollowStatus(accountId, () => {
        dispatch(
          updateCollectionEditorField({
            field: 'accountIds',
            value: [...accountIds, accountId],
          }),
        );
      });
    },
    [accountIds, confirmFollowStatus, dispatch],
  );

  const toggleAccountItem = useCallback(
    (item: SuggestionItem) => {
      if (accountIds.includes(item.id)) {
        removeAccountItem(item.id);
      } else {
        addAccountItem(item.id);
      }
    },
    [accountIds, addAccountItem, removeAccountItem],
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
    (collectionId: string, accountId: string) => {
      confirmFollowStatus(accountId, () => {
        void dispatch(addCollectionItem({ collectionId, accountId }));
      });
    },
    [confirmFollowStatus, dispatch],
  );

  const instantToggleAccountItem = useCallback(
    (item: SuggestionItem) => {
      if (accountIds.includes(item.id)) {
        instantRemoveAccountItem(item.id);
      } else if (id) {
        instantAddAccountItem(id, item.id);
      }
    },
    [accountIds, id, instantAddAccountItem, instantRemoveAccountItem],
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
  const inputLabel = intl.formatMessage({
    id: 'collections.search_accounts_label',
    defaultMessage: 'Search for accounts to add…',
  });

  return (
    <form onSubmit={handleSubmit} className={classes.form}>
      <FormStack className={classes.formFieldStack}>
        {!id && (
          <WizardStepHeader
            step={1}
            title={
              <FormattedMessage
                id='collections.create.accounts_title'
                defaultMessage='Who will you feature in this collection?'
              />
            }
            description={
              <FormattedMessage
                id='collections.create.accounts_subtitle'
                defaultMessage='Only accounts you follow who have opted into discovery can be added.'
              />
            }
          />
        )}
        <label htmlFor={inputId} className='sr-only'>
          {inputLabel}
        </label>
        <Combobox
          id={inputId}
          placeholder={inputLabel}
          value={hasMaxAccounts ? '' : searchValue}
          onChange={handleSearchValueChange}
          onKeyDown={handleSearchKeyDown}
          disabled={hasMaxAccounts}
          isLoading={isLoadingSuggestions}
          items={suggestedItems}
          getItemId={getItemId}
          getIsItemSelected={getIsItemSelected}
          renderItem={renderAccountItem}
          onSelectItem={
            isEditMode ? instantToggleAccountItem : toggleAccountItem
          }
          closeOnSelect={false}
        />
        {hasMaxAccounts && (
          <FormattedMessage
            id='collections.search_accounts_max_reached'
            defaultMessage='You have added the maximum number of accounts'
          />
        )}

        <Scrollable className={classes.scrollableWrapper}>
          <ItemList
            className={classes.scrollableInner}
            emptyMessage={
              <EmptyState
                title={
                  <FormattedMessage
                    id='collections.accounts.empty_title'
                    defaultMessage='This collection is empty'
                  />
                }
                message={
                  <FormattedMessage
                    id='collections.accounts.empty_description'
                    defaultMessage='Add up to {count} accounts you follow'
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
      </FormStack>
      {!isEditMode && (
        <div className={classes.stickyFooter}>
          <div className={classes.actionWrapper}>
            <FormattedMessage
              id='collections.hints.accounts_counter'
              defaultMessage='{count} / {max} accounts'
              values={{ count: accountIds.length, max: MAX_ACCOUNT_COUNT }}
            >
              {(text) => <div className={classes.itemCountReadout}>{text}</div>}
            </FormattedMessage>
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
        </div>
      )}
    </form>
  );
};
