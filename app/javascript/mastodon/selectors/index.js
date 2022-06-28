import { createSelector } from 'reselect';
import { List as ImmutableList, Map as ImmutableMap, is } from 'immutable';
import { me } from '../initial_state';

const getAccountBase         = (state, id) => state.getIn(['accounts', id], null);
const getAccountCounters     = (state, id) => state.getIn(['accounts_counters', id], null);
const getAccountRelationship = (state, id) => state.getIn(['relationships', id], null);
const getAccountMoved        = (state, id) => state.getIn(['accounts', state.getIn(['accounts', id, 'moved'])]);

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

const toServerSideType = columnType => {
  switch (columnType) {
  case 'home':
  case 'notifications':
  case 'public':
  case 'thread':
  case 'account':
    return columnType;
  default:
    if (columnType.indexOf('list:') > -1) {
      return 'home';
    } else {
      return 'public'; // community, account, hashtag
    }
  }
};

const escapeRegExp = string =>
  string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string

const regexFromKeywords = keywords => {
  if (keywords.size === 0) {
    return null;
  }

  return new RegExp(keywords.map(keyword_filter => {
    let expr = escapeRegExp(keyword_filter.get('keyword'));

    if (keyword_filter.get('whole_word')) {
      if (/^[\w]/.test(expr)) {
        expr = `\\b${expr}`;
      }

      if (/[\w]$/.test(expr)) {
        expr = `${expr}\\b`;
      }
    }

    return expr;
  }).join('|'), 'i');
};

const regexFromFilters = filters => {
  return filters.map(filter => [regexFromKeywords(filter.get('keywords')), filter.get('title')]);
};

// Memoize the filter regexps for each valid server contextType
const makeGetFiltersRegex = () => {
  let memo = {};

  return (state, { contextType }) => {
    if (!contextType) return [null, null];

    const serverSideType = toServerSideType(contextType);
    const now = new Date();
    const filters = state.get('filters', ImmutableMap()).toList().filter(filter => filter.get('context').includes(serverSideType) && filter.get('keywords') && filter.get('keywords').size > 0 && (filter.get('expires_at') === null || filter.get('expires_at') > now));

    if (!memo[serverSideType] || !is(memo[serverSideType].filters, filters)) {
      const dropRegex = regexFromKeywords(filters.filter(filter => filter.get('filter_action') === 'hide').flatMap(filter => filter.get('keywords')));
      const regexes = regexFromFilters(filters.filter(filter => filter.get('filter_action') !== 'hide'));
      memo[serverSideType] = { filters: filters, results: [dropRegex, regexes] };
    }
    return memo[serverSideType].results;
  };
};

export const getFiltersRegex = makeGetFiltersRegex();

const getPartialFilters = (state, { contextType }) => {
  if (!contextType) return null;

  const serverSideType = toServerSideType(contextType);
  const now = new Date();

  return state.get('filters').filter((filter) => filter.get('context').includes(serverSideType) && !filter.get('keywords') && (filter.get('expires_at') === null || filter.get('expires_at') > now));
};

export const makeGetStatus = () => {
  return createSelector(
    [
      (state, { id }) => state.getIn(['statuses', id]),
      (state, { id }) => state.getIn(['statuses', state.getIn(['statuses', id, 'reblog'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', id, 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account'])]),
      getFiltersRegex,
      getPartialFilters,
    ],

    (statusBase, statusReblog, accountBase, accountReblog, filtersRegex, partialFilters) => {
      if (!statusBase) {
        return null;
      }

      if (statusReblog) {
        statusReblog = statusReblog.set('account', accountReblog);
      } else {
        statusReblog = null;
      }

      let filtered = false;
      if ((accountReblog || accountBase).get('id') !== me) {
        const search_index = statusBase.get('reblog') ? statusReblog.get('search_index') : statusBase.get('search_index');
        const dropRegex = filtersRegex[0];
        if (dropRegex && dropRegex.test(search_index)) {
          return null;
        }

        if (filtersRegex[1]) {
          const filterResults = filtersRegex[1].filter(f => f[0] && f[0].test(search_index)).map(f => f[1]);
          if (!filterResults.isEmpty()) {
            filtered = filterResults;
          }
        }

        // Handle partial filters
        if (partialFilters) {
          let filterResults = statusReblog?.get('filtered') || statusBase.get('filtered') || ImmutableList();
          if (filterResults.some((result) => partialFilters.getIn([result.get('filter'), 'filter_action']) === 'hide')) {
            return null;
          }
          if (!filterResults.isEmpty()) {
            filtered = filterResults.map(result => partialFilters.getIn([result.get('filter'), 'title']));
          }
        }
      }

      return statusBase.withMutations(map => {
        map.set('reblog', statusReblog);
        map.set('account', accountBase);
        map.set('filtered', filtered);
      });
    },
  );
};

export const makeGetPictureInPicture = () => {
  return createSelector([
    (state, { id }) => state.get('picture_in_picture').statusId === id,
    (state) => state.getIn(['meta', 'layout']) !== 'mobile',
  ], (inUse, available) => ImmutableMap({
    inUse: inUse && available,
    available,
  }));
};

const getAlertsBase = state => state.get('alerts');

export const getAlerts = createSelector([getAlertsBase], (base) => {
  let arr = [];

  base.forEach(item => {
    arr.push({
      message: item.get('message'),
      message_values: item.get('message_values'),
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
    (state, _, accountId) => state.getIn(['accounts', accountId]),
  ], (base, account) => {
    return base.set('account', account);
  });
};

export const getAccountGallery = createSelector([
  (state, id) => state.getIn(['timelines', `account:${id}:media`, 'items'], ImmutableList()),
  state       => state.get('statuses'),
  (state, id) => state.getIn(['accounts', id]),
], (statusIds, statuses, account) => {
  let medias = ImmutableList();

  statusIds.forEach(statusId => {
    const status = statuses.get(statusId);
    medias = medias.concat(status.get('media_attachments').map(media => media.set('status', status).set('account', account)));
  });

  return medias;
});

export const getAccountHidden = createSelector([
  (state, id) => state.getIn(['accounts', id, 'hidden']),
  (state, id) => state.getIn(['relationships', id, 'following']) || state.getIn(['relationships', id, 'requested']),
  (state, id) => id === me,
], (hidden, followingOrRequested, isSelf) => {
  return hidden && !(isSelf || followingOrRequested);
});
