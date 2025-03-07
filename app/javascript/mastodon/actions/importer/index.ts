import { createAction } from '@reduxjs/toolkit';

import type { ApiAccountJSON } from 'mastodon/api_types/accounts';
import type { ApiStatusJSON, ApiFilterJSON } from 'mastodon/api_types/statuses';
import type { Poll } from 'mastodon/models/poll';
import { createPollFromServerJSON } from 'mastodon/models/poll';
import type { AppDispatch, RootState } from 'mastodon/store';

import { normalizeStatus } from './normalizer';
import { importPolls } from './polls';

export const STATUS_IMPORT = 'STATUS_IMPORT';
export const STATUSES_IMPORT = 'STATUSES_IMPORT';
export const FILTERS_IMPORT = 'FILTERS_IMPORT';

export const importAccounts = createAction<{ accounts: ApiAccountJSON[] }>(
  'accounts/importAccounts',
);

interface Identifiable {
  id: string;
}

const pushUnique = (array: Identifiable[], object: Identifiable) => {
  if (array.every((element) => element.id !== object.id)) {
    array.push(object);
  }
};

export const importStatus = (status: ApiStatusJSON) => {
  return { type: STATUS_IMPORT, status };
};

export const importStatuses = (statuses: ApiStatusJSON[]) => {
  return { type: STATUSES_IMPORT, statuses };
};

export const importFilters = (filters: unknown[]) => {
  return { type: FILTERS_IMPORT, filters };
};

export const importFetchedAccount = (account: ApiAccountJSON) => {
  return importFetchedAccounts([account]);
};

export const importFetchedAccounts = (accounts: ApiAccountJSON[]) => {
  const normalAccounts: ApiAccountJSON[] = [];

  function processAccount(account: ApiAccountJSON) {
    pushUnique(normalAccounts, account);

    if (account.moved) {
      processAccount(account.moved);
    }
  }

  accounts.forEach(processAccount);

  return importAccounts({ accounts: normalAccounts });
};

export const importFetchedStatus = (status: ApiStatusJSON) => {
  return importFetchedStatuses([status]);
};

export const importFetchedStatuses = (statuses: ApiStatusJSON[]) => {
  return (dispatch: AppDispatch, getState: () => RootState) => {
    const accounts: ApiAccountJSON[] = [];
    const normalStatuses: ApiStatusJSON[] = [];
    const polls: Poll[] = [];
    const filters: ApiFilterJSON[] = [];

    function processStatus(status: ApiStatusJSON) {
      pushUnique(
        normalStatuses,
        normalizeStatus(
          status,
          getState().statuses.get(status.id),
        ) as ApiStatusJSON,
      );
      pushUnique(accounts, status.account);

      if (status.filtered) {
        status.filtered.forEach((result) => {
          pushUnique(filters, result.filter);
        });
      }

      if (status.reblog?.id) {
        processStatus(status.reblog);
      }

      if (status.poll?.id) {
        pushUnique(
          polls,
          createPollFromServerJSON(
            status.poll,
            getState().polls.get(status.poll.id),
          ),
        );
      }

      if (status.card) {
        status.card.authors.forEach((author) => {
          if (author.account) pushUnique(accounts, author.account);
        });
      }
    }

    statuses.forEach(processStatus);

    dispatch(importPolls({ polls }));
    dispatch(importFetchedAccounts(accounts));
    dispatch(importStatuses(normalStatuses));
    dispatch(importFilters(filters));
  };
};
