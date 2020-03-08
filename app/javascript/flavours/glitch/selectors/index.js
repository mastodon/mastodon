import escapeTextContentForBrowser from 'escape-html';
import { createSelector } from 'reselect';
import { List as ImmutableList, is } from 'immutable';
import { me } from 'flavours/glitch/util/initial_state';

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

export const toServerSideType = columnType => {
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

export const regexFromFilters = filters => {
  if (filters.size === 0) {
    return null;
  }

  return new RegExp(filters.map(filter => {
    let expr = escapeRegExp(filter.get('phrase'));

    if (filter.get('whole_word')) {
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

// Memoize the filter regexps for each valid server contextType
const makeGetFiltersRegex = () => {
  let memo = {};

  return (state, { contextType }) => {
    if (!contextType) return ImmutableList();

    const serverSideType = toServerSideType(contextType);
    const filters = state.get('filters', ImmutableList()).filter(filter => filter.get('context').includes(serverSideType) && (filter.get('expires_at') === null || Date.parse(filter.get('expires_at')) > (new Date())));

    if (!memo[serverSideType] || !is(memo[serverSideType].filters, filters)) {
      const dropRegex = regexFromFilters(filters.filter(filter => filter.get('irreversible')));
      const regex = regexFromFilters(filters);
      memo[serverSideType] = { filters: filters, results: [dropRegex, regex] };
    }
    return memo[serverSideType].results;
  };
};

export const getFiltersRegex = makeGetFiltersRegex();

export const makeGetStatus = () => {
  return createSelector(
    [
      (state, { id }) => state.getIn(['statuses', id]),
      (state, { id }) => state.getIn(['statuses', state.getIn(['statuses', id, 'reblog'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', id, 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account'])]),
      (state, _) => state.getIn(['local_settings', 'filtering_behavior']),
      (state, _) => state.get('filters', ImmutableList()),
      (_, { contextType }) => contextType,
      getFiltersRegex,
    ],

    (statusBase, statusReblog, accountBase, accountReblog, filteringBehavior, filters, contextType, filtersRegex) => {
      if (!statusBase) {
        return null;
      }

      const dropRegex = (accountReblog || accountBase).get('id') !== me && filtersRegex[0];

      if (dropRegex && dropRegex.test(statusBase.get('reblog') ? statusReblog.get('search_index') : statusBase.get('search_index'))) {
        return null;
      }

      const regex  = (accountReblog || accountBase).get('id') !== me && filtersRegex[1];
      let filtered = false;

      if (statusReblog) {
        filtered     = regex && regex.test(statusReblog.get('search_index'));
        statusReblog = statusReblog.set('account', accountReblog);
        statusReblog = statusReblog.set('filtered', filtered);
      } else {
        statusReblog = null;
      }

      filtered = filtered || regex && regex.test(statusBase.get('search_index'));

      if (filtered && filteringBehavior === 'drop') {
        return null;
      } else if (filtered && filteringBehavior === 'content_warning') {
        let spoilerText = (statusReblog || statusBase).get('spoiler_text', '');
        const searchIndex = (statusReblog || statusBase).get('search_index');
        const serverSideType = toServerSideType(contextType);
        const enabledFilters = filters.filter(filter => filter.get('context').includes(serverSideType) && (filter.get('expires_at') === null || Date.parse(filter.get('expires_at')) > (new Date()))).toArray();
        const matchingFilters = enabledFilters.filter(filter => {
          const regexp = regexFromFilters([filter]);
          return regexp.test(searchIndex) && !regexp.test(spoilerText);
        });
        if (statusReblog) {
          statusReblog = statusReblog.set('spoiler_text', matchingFilters.map(filter => filter.get('phrase')).concat([spoilerText]).filter(cw => !!cw).join(', '));
          statusReblog = statusReblog.update('spoilerHtml', '', spoilerText => matchingFilters.map(filter => escapeTextContentForBrowser(filter.get('phrase'))).concat([spoilerText]).filter(cw => !!cw).join(', '));
        } else {
          statusBase = statusBase.set('spoiler_text', matchingFilters.map(filter => filter.get('phrase')).concat([spoilerText]).filter(cw => !!cw).join(', '));
          statusBase = statusBase.update('spoilerHtml', '', spoilerText => matchingFilters.map(filter => escapeTextContentForBrowser(filter.get('phrase'))).concat([spoilerText]).filter(cw => !!cw).join(', '));
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
], (statusIds, statuses) => {
  let medias = ImmutableList();

  statusIds.forEach(statusId => {
    const status = statuses.get(statusId);
    medias = medias.concat(status.get('media_attachments').map(media => media.set('status', status)));
  });

  return medias;
});
