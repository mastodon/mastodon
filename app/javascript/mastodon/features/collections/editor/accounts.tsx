import { useCallback, useMemo, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory, useLocation } from 'react-router-dom';

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
import { Callout } from 'mastodon/components/callout';
import { DisplayName } from 'mastodon/components/display_name';
import { EmptyState } from 'mastodon/components/empty_state';
import { FormStack, ComboboxField } from 'mastodon/components/form_fields';
import { Icon } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import ScrollableList from 'mastodon/components/scrollable_list';
import { useSearchAccounts } from 'mastodon/features/lists/use_search_accounts';
import { useAccount } from 'mastodon/hooks/useAccount';
import { me } from 'mastodon/initial_state';
import {
  addCollectionItem,
  removeCollectionItem,
} from 'mastodon/reducers/slices/collections';
import { store, useAppDispatch, useAppSelector } from 'mastodon/store';

import type { TempCollectionState } from './state';
import { getCollectionEditorState } from './state';
import classes from './styles.module.scss';
import { WizardStepHeader } from './wizard_step_header';

const MIN_ACCOUNT_COUNT = 1;
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
  isRemovable: boolean;
  onRemove: (id: string) => void;
}> = ({ accountId, isRemovable, onRemove }) => {
  const intl = useIntl();
  const account = useAccount(accountId);

  const handleRemoveAccount = useCallback(() => {
    onRemove(accountId);
  }, [accountId, onRemove]);

  const lastPostHint = useMemo(
    () =>
      isOlderThanAWeek(account?.last_status_at) && (
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
    [account?.last_status_at],
  );

  return (
    <Account
      minimal
      key={accountId}
      id={accountId}
      extraAccountInfo={lastPostHint}
    >
      {isRemovable && (
        <IconButton
          title={intl.formatMessage({
            id: 'collections.remove_account',
            defaultMessage: 'Remove this account',
          })}
          icon='remove'
          iconComponent={CancelIcon}
          onClick={handleRemoveAccount}
        />
      )}
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
  const location = useLocation<TempCollectionState>();
  const { id, initialItemIds } = getCollectionEditorState(
    collection,
    location.state,
  );
  const isEditMode = !!id;
  const collectionItems = collection?.items;

  const [searchValue, setSearchValue] = useState('');
  // This state is only used when creating a new collection.
  // In edit mode, the collection will be updated instantly
  const [addedAccountIds, setAccountIds] = useState(initialItemIds);
  const accountIds = useMemo(
    () =>
      isEditMode
        ? (collectionItems
            ?.map((item) => item.account_id)
            .filter((id): id is string => !!id) ?? [])
        : addedAccountIds,
    [isEditMode, collectionItems, addedAccountIds],
  );

  const hasMaxAccounts = accountIds.length === MAX_ACCOUNT_COUNT;
  const hasMinAccounts = accountIds.length === MIN_ACCOUNT_COUNT;
  const hasTooFewAccounts = accountIds.length < MIN_ACCOUNT_COUNT;
  const canSubmit = !hasTooFewAccounts;

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

  const removeAccountItem = useCallback((accountId: string) => {
    setAccountIds((ids) => ids.filter((id) => id !== accountId));
  }, []);

  const addAccountItem = useCallback(
    (accountId: string) => {
      confirmFollowStatus(accountId, () => {
        setAccountIds((ids) => [...ids, accountId]);
      });
    },
    [confirmFollowStatus],
  );

  const toggleAccountItem = useCallback(
    (item: SuggestionItem) => {
      if (addedAccountIds.includes(item.id)) {
        removeAccountItem(item.id);
      } else {
        addAccountItem(item.id);
      }
    },
    [addAccountItem, addedAccountIds, removeAccountItem],
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

      if (!canSubmit) {
        return;
      }

      if (!id) {
        history.push(`/collections/new/details`, {
          account_ids: accountIds,
        });
      }
    },
    [canSubmit, id, history, accountIds],
  );

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
        <ComboboxField
          label={
            <FormattedMessage
              id='collections.search_accounts_label'
              defaultMessage='Search for accounts to add…'
            />
          }
          hint={
            hasMaxAccounts ? (
              <FormattedMessage
                id='collections.search_accounts_max_reached'
                defaultMessage='You have added the maximum number of accounts'
              />
            ) : undefined
          }
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
        />

        {hasMinAccounts && (
          <Callout>
            <FormattedMessage
              id='collections.hints.can_not_remove_more_accounts'
              defaultMessage='Collections must contain at least {count, plural, one {# account} other {# accounts}}. Removing more accounts is not possible.'
              values={{ count: MIN_ACCOUNT_COUNT }}
            />
          </Callout>
        )}

        <div className={classes.scrollableWrapper}>
          <ScrollableList
            scrollKey='collection-items'
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
            // TODO: Re-add `bindToDocument={!multiColumn}`
          >
            {accountIds.map((accountId) => (
              <AddedAccountItem
                key={accountId}
                accountId={accountId}
                isRemovable={!isEditMode || !hasMinAccounts}
                onRemove={handleRemoveAccountItem}
              />
            ))}
          </ScrollableList>
        </div>
      </FormStack>
      {!isEditMode && (
        <div className={classes.stickyFooter}>
          {hasTooFewAccounts ? (
            <Callout icon={false} className={classes.submitDisabledCallout}>
              <FormattedMessage
                id='collections.hints.add_more_accounts'
                defaultMessage='Add at least {count, plural, one {# account} other {# accounts}} to continue'
                values={{ count: MIN_ACCOUNT_COUNT }}
              />
            </Callout>
          ) : (
            <div className={classes.actionWrapper}>
              <FormattedMessage
                id='collections.hints.accounts_counter'
                defaultMessage='{count} / {max} accounts'
                values={{ count: accountIds.length, max: MAX_ACCOUNT_COUNT }}
              >
                {(text) => (
                  <div className={classes.itemCountReadout}>{text}</div>
                )}
              </FormattedMessage>
              {canSubmit && (
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
              )}
            </div>
          )}
        </div>
      )}
    </form>
  );
};
