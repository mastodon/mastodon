import { createSelector } from 'reselect'
import Immutable          from 'immutable';

const getStatuses = state => state.getIn(['timelines', 'statuses']);
const getAccounts = state => state.getIn(['timelines', 'accounts']);

const getAccountBase         = (state, id) => state.getIn(['timelines', 'accounts', id], null);
const getAccountRelationship = (state, id) => state.getIn(['timelines', 'relationships', id]);

export const getAccount = createSelector([getAccountBase, getAccountRelationship], (base, relationship) => {
  if (base === null) {
    return null;
  }

  return base.set('relationship', relationship);
});

const getStatusBase = (state, id) => state.getIn(['timelines', 'statuses', id], null);

export const makeGetStatus = () => {
  return createSelector([getStatusBase, getStatuses, getAccounts], (base, statuses, accounts) => {
    if (base === null) {
      return null;
    }

    return assembleStatus(base.get('id'), statuses, accounts);
  });
};

const assembleStatus = (id, statuses, accounts) => {
  let status = statuses.get(id, null);
  let reblog = null;

  if (status === null) {
    return null;
  }

  if (status.get('reblog', null) !== null) {
    reblog = statuses.get(status.get('reblog'), null);

    if (reblog !== null) {
      reblog = reblog.set('account', accounts.get(reblog.get('account')));
    } else {
      return null;
    }
  }

  return status.set('reblog', reblog).set('account', accounts.get(status.get('account')));
};

const getNotificationsBase = state => state.get('notifications');

export const getNotifications = createSelector([getNotificationsBase], (base) => {
  let arr = [];

  base.forEach(item => {
    arr.push({
      message: item.get('message'),
      title: item.get('title'),
      key: item.get('key'),
      dismissAfter: 5000
    });
  });

  return arr;
});

const getSuggestionsBase = (state) => state.getIn(['timelines', 'suggestions']);

export const getSuggestions = createSelector([getSuggestionsBase, getAccounts], (base, accounts) => {
  return base.map(accountId => accounts.get(accountId));
});
