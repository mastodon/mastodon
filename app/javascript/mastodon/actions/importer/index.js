import { createPollFromServerJSON } from 'mastodon/models/poll';

import { importAccounts } from './accounts';
import { importCustomEmoji } from './emoji';
import { normalizeStatus } from './normalizer';
import { importPolls } from './polls';

export const STATUS_IMPORT   = 'STATUS_IMPORT';
export const STATUSES_IMPORT = 'STATUSES_IMPORT';
export const FILTERS_IMPORT  = 'FILTERS_IMPORT';

function pushUnique(array, object) {
  if (array.every(element => element.id !== object.id)) {
    array.push(object);
  }
}

export function importStatus(status) {
  return { type: STATUS_IMPORT, status };
}

export function importStatuses(statuses) {
  return { type: STATUSES_IMPORT, statuses };
}

export function importFilters(filters) {
  return { type: FILTERS_IMPORT, filters };
}

export function importFetchedAccount(account) {
  return importFetchedAccounts([account]);
}

export function importFetchedAccounts(accounts) {
  const normalAccounts = [];

  function processAccount(account) {
    pushUnique(normalAccounts, account);

    if (account.moved) {
      processAccount(account.moved);
    }

    if (account.emojis && account.username === account.acct) {
      importCustomEmoji(account.emojis);
    }
  }

  accounts.forEach(processAccount);

  return importAccounts({ accounts: normalAccounts });
}

export function importFetchedStatus(status, options = {}) {
  return importFetchedStatuses([status], options);
}

export function importFetchedStatuses(statuses, options = {}) {
  return (dispatch, getState) => {
    const accounts = [];
    const normalStatuses = [];
    const polls = [];
    const filters = [];

    function processStatus(status) {
      pushUnique(normalStatuses, normalizeStatus(status, getState().getIn(['statuses', status.id]), options));
      pushUnique(accounts, status.account);

      if (status.filtered) {
        status.filtered.forEach(result => pushUnique(filters, result.filter));
      }

      if (status.reblog?.id) {
        processStatus(status.reblog);
      }

      if (status.quote?.quoted_status) {
        processStatus(status.quote.quoted_status);
      }

      if (status.poll?.id) {
        pushUnique(polls, createPollFromServerJSON(status.poll, getState().polls[status.poll.id]));
      }

      if (status.card) {
        status.card.authors.forEach(author => author.account && pushUnique(accounts, author.account));
      }

      if (status.emojis && status.account.username === status.account.acct) {
        importCustomEmoji(status.emojis);
      }
    }

    statuses.forEach(processStatus);

    dispatch(importPolls({ polls }));
    dispatch(importFetchedAccounts(accounts));
    dispatch(importStatuses(normalStatuses));
    dispatch(importFilters(filters));
  };
}
