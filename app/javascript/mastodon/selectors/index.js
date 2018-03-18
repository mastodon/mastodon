import { createSelector } from 'reselect';
import { List as ImmutableList } from 'immutable';

const getAccountBase         = (state, id) => state.accounts.get(id, null);
const getAccountCounters     = (state, id) => state.accounts_counters.get(id, null);
const getAccountRelationship = (state, id) => state.relationships.get(id, null);
const getAccountMoved        = (state, id) => state.accounts.get(state.accounts.getIn([id, 'moved']));

export const makeGetAccount = () => {
  return createSelector([getAccountBase, getAccountCounters, getAccountRelationship, getAccountMoved], (base, counters, relationship, moved) => {
    if (base === null) {
      return null;
    }

    return base.merge(counters).withMutations(map => {
      map.set('relationship', relationship);
      map.set('moved', moved);
    });
  });
};

export const makeGetStatus = () => {
  return createSelector(
    [
      (state, id) => state.statuses.get(id),
      (state, id) => state.statuses.get(state.statuses.getIn([id, 'reblog'])),
      (state, id) => state.accounts.get(state.statuses.getIn([id, 'account'])),
      (state, id) => state.accounts.get(state.statuses.getIn([state.statuses.getIn([id, 'reblog']), 'account'])),
    ],

    (statusBase, statusReblog, accountBase, accountReblog) => {
      if (!statusBase) {
        return null;
      }

      if (statusReblog) {
        statusReblog = statusReblog.set('account', accountReblog);
      } else {
        statusReblog = null;
      }

      return statusBase.withMutations(map => {
        map.set('reblog', statusReblog);
        map.set('account', accountBase);
      });
    }
  );
};

const getAlertsBase = state => state.alerts;

export const getAlerts = createSelector([getAlertsBase], (base) => {
  let arr = [];

  base.forEach(item => {
    arr.push({
      message: item.get('message'),
      title: item.get('title'),
      key: item.get('key'),
      dismissAfter: 5000,
      barStyle: {
        zIndex: 200,
      },
    });
  });

  return arr;
});

export const makeGetNotification = () => {
  return createSelector([
    (_, base)             => base,
    (state, _, accountId) => state.accounts.get(accountId),
  ], (base, account) => {
    return base.set('account', account);
  });
};

export const getAccountGallery = createSelector([
  (state, id) => state.timelines.getIn([`account:${id}:media`, 'items'], ImmutableList()),
  state       => state.statuses,
], (statusIds, statuses) => {
  let medias = ImmutableList();

  statusIds.forEach(statusId => {
    const status = statuses.get(statusId);
    medias = medias.concat(status.get('media_attachments').map(media => media.set('status', status)));
  });

  return medias;
});
