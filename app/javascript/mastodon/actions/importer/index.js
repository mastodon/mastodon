import { autoPlayGif } from '../../initial_state';
import { putAccounts, putStatuses } from '../../storage/modifier';
import { normalizeAccount, normalizeStatus } from './normalizer';

export const ACCOUNT_IMPORT = 'ACCOUNT_IMPORT';
export const ACCOUNTS_IMPORT = 'ACCOUNTS_IMPORT';
export const STATUS_IMPORT = 'STATUS_IMPORT';
export const STATUSES_IMPORT = 'STATUSES_IMPORT';

function pushUnique(array, object) {
  if (array.every(element => element.id !== object.id)) {
    array.push(object);
  }
}

export function importAccount(account) {
  return { type: ACCOUNT_IMPORT, account };
}

export function importAccounts(accounts) {
  return { type: ACCOUNTS_IMPORT, accounts };
}

export function importStatus(status) {
  return { type: STATUS_IMPORT, status };
}

export function importStatuses(statuses) {
  return { type: STATUSES_IMPORT, statuses };
}

export function importFetchedAccount(account) {
  return importFetchedAccounts([account]);
}

export function importFetchedAccounts(accounts) {
  const normalAccounts = [];

  function processAccount(account) {
    pushUnique(normalAccounts, normalizeAccount(account));

    if (account.moved) {
      processAccount(account.moved);
    }
  }

  accounts.forEach(processAccount);
  putAccounts(normalAccounts, !autoPlayGif);

  return importAccounts(normalAccounts);
}

export function importFetchedStatus(status) {
  return importFetchedStatuses([status]);
}

export function importFetchedStatuses(statuses) {
  return (dispatch, getState) => {
    const accounts = [];
    const normalStatuses = [];

    function processStatus(status) {
      pushUnique(normalStatuses, normalizeStatus(status, getState().getIn(['statuses', status.id])));
      pushUnique(accounts, status.account);

      if (status.reblog && status.reblog.id) {
        processStatus(status.reblog);
      }
    }

    statuses.forEach(processStatus);
    putStatuses(normalStatuses);

    dispatch(importFetchedAccounts(accounts));
    dispatch(importStatuses(normalStatuses));
  };
}
