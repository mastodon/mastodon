import { useCallback, useId, useMemo, useState } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import type { Map as ImmutableMap } from 'immutable';

import { useComboboxItemProps } from '@/mastodon/components/form_fields/combobox_field';
import type { ApiMutedAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { AccountListItem } from 'mastodon/components/account_list_item';
import { Avatar } from 'mastodon/components/avatar';
import { Button } from 'mastodon/components/button';
import { DisplayName } from 'mastodon/components/display_name';
import { useAccountHandle } from 'mastodon/components/display_name/default';
import { EmptyState } from 'mastodon/components/empty_state';
import { FormStack, ComboboxField } from 'mastodon/components/form_fields';
import {
  ListItemContent,
  ListItemWrapper,
} from 'mastodon/components/list_item';
import {
  Article,
  ItemList,
  Scrollable,
} from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useSearchAccounts } from 'mastodon/hooks/useSearchAccounts';
import { domain } from 'mastodon/initial_state';
import type { Relationship } from 'mastodon/models/relationship';
import {
  addCollectionItem,
  getCollectionItemIds,
  removeCollectionItem,
  updateCollectionEditorField,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

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

const SuggestedAccountItem: React.FC<{ id: string }> = ({ id }) => {
  const account = useAccount(id);
  const handle = useAccountHandle(account, domain);
  const comboboxItemProps = useComboboxItemProps();

  if (!account) return null;

  return (
    <li {...comboboxItemProps} className={classes.suggestion}>
      <ListItemWrapper icon={<Avatar account={account} size={40} />}>
        <ListItemContent subtitle={handle}>
          <DisplayName account={account} variant='simple' />
        </ListItemContent>
      </ListItemWrapper>
    </li>
  );
};

const renderAccountItem = (account: ApiMutedAccountJSON) => (
  <SuggestedAccountItem id={account.id} />
);

type GroupKey = 'available' | 'mustFollow' | 'disabled';

const canAccountBeAdded = (account: ApiMutedAccountJSON) =>
  ['automatic', 'manual'].includes(account.feature_approval.current_user);

function groupSuggestions(
  accounts: ApiMutedAccountJSON[],
  relationships: ImmutableMap<string, Relationship>,
) {
  const { available, mustFollow, disabled } = Object.groupBy(
    accounts,
    (account): GroupKey => {
      if (canAccountBeAdded(account)) {
        return 'available';
      }

      const canAccountBeAddedByFollowers =
        account.feature_approval.automatic.includes('followers') ||
        account.feature_approval.manual.includes('followers');

      if (
        canAccountBeAddedByFollowers &&
        !relationships.get(account.id)?.following
      ) {
        return 'mustFollow';
      }

      return 'disabled';
    },
  );

  // Returning a new object ensures a fixed property order
  return { available, mustFollow, disabled };
}

const renderGroupTitle = (groupKey: GroupKey, titleId: string) => {
  if (groupKey === 'available') {
    return null;
  }

  let title: React.ReactElement;
  let description: React.ReactElement;

  if (groupKey === 'mustFollow') {
    title = (
      <FormattedMessage
        id='collections.suggestions.must_follow'
        defaultMessage='Must follow first'
      />
    );
    description = (
      <FormattedMessage
        id='collections.suggestions.must_follow_desc'
        defaultMessage='These accounts review all follow requests. Followers can add them to collections.'
      />
    );
  } else {
    title = (
      <FormattedMessage
        id='collections.suggestions.can_not_add'
        defaultMessage='Can’t be added'
      />
    );
    description = (
      <FormattedMessage
        id='collections.suggestions.can_not_add_desc'
        defaultMessage='These accounts may have opted out of discovery, or they might be on a server that doesn’t support collections.'
      />
    );
  }

  return (
    <li role='presentation'>
      <ListItemWrapper className={classes.suggestionGroup}>
        <ListItemContent id={titleId} subtitle={description}>
          {title}
        </ListItemContent>
      </ListItemWrapper>
    </li>
  );
};

const getItemId = (account: ApiMutedAccountJSON) => account.id;
const getIsItemDisabled = (account: ApiMutedAccountJSON) =>
  !canAccountBeAdded(account);

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
    // Don't suggest accounts that were already added
    filterResults: (account) => !accountIds.includes(account.id),
  });

  const relationships = useAppSelector((state) => state.relationships);

  const groupedItems = groupSuggestions(suggestedAccounts, relationships);

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
    (item: ApiMutedAccountJSON) => {
      dispatch(
        updateCollectionEditorField({
          field: 'accountIds',
          value: [...accountIds, item.id],
        }),
      );
    },
    [accountIds, dispatch],
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
    (item: ApiMutedAccountJSON) => {
      if (id) {
        void dispatch(
          addCollectionItem({ collectionId: id, accountId: item.id }),
        );
      }
    },
    [dispatch, id],
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
    (item: ApiMutedAccountJSON) => {
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
            items={groupedItems}
            getItemId={getItemId}
            getIsItemDisabled={getIsItemDisabled}
            renderItem={renderAccountItem}
            renderGroupTitle={renderGroupTitle}
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
