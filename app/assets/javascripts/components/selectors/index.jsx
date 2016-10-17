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

export const getStatus = createSelector([getStatusBase, getStatuses, getAccounts], (base, statuses, accounts) => {
  if (base === null) {
    return null;
  }

  return assembleStatus(base.get('id'), statuses, accounts);
});

const getAccountTimelineIds = (state, id) => state.getIn(['timelines', 'accounts_timelines', id], Immutable.List());

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

  console.log('assembly for status', id, reblog.toJS());

  return status.set('reblog', reblog).set('account', accounts.get(status.get('account')));
};

const assembleStatusList = (ids, statuses, accounts) => {
  return ids.map(statusId => assembleStatus(statusId, statuses, accounts)).filterNot(status => status === null);
};

export const getAccountTimeline = createSelector([getAccountTimelineIds, getStatuses, getAccounts], assembleStatusList);

const getTimelineIds = (state, timelineType) => state.getIn(['timelines', timelineType]);

export const makeGetTimeline = () => {
  return createSelector([getTimelineIds, getStatuses, getAccounts], assembleStatusList);
};

const getStatusAncestorsIds = (state, id) => state.getIn(['timelines', 'ancestors', id], Immutable.OrderedSet());

export const getStatusAncestors = createSelector([getStatusAncestorsIds, getStatuses, getAccounts], assembleStatusList);

const getStatusDescendantsIds = (state, id) => state.getIn(['timelines', 'descendants', id], Immutable.OrderedSet());

export const getStatusDescendants = createSelector([getStatusDescendantsIds, getStatuses, getAccounts], assembleStatusList);

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
