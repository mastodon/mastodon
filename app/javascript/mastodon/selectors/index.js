import { createSelector } from '@reduxjs/toolkit';
import { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { me } from '../initial_state';

import { getFilters } from './filters';

export { makeGetAccount } from "./accounts";

export const makeGetStatus = () => {
  return createSelector(
    [
      (state, { id }) => state.getIn(['statuses', id]),
      (state, { id }) => state.getIn(['statuses', state.getIn(['statuses', id, 'reblog'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', id, 'account'])]),
      (state, { id }) => state.getIn(['accounts', state.getIn(['statuses', state.getIn(['statuses', id, 'reblog']), 'account'])]),
      getFilters,
      (_, { contextType }) => ['detailed', 'bookmarks', 'favourites'].includes(contextType),
    ],

    (statusBase, statusReblog, accountBase, accountReblog, filters, warnInsteadOfHide) => {
      if (!statusBase || statusBase.get('isLoading')) {
        return null;
      }

      if (statusReblog) {
        statusReblog = statusReblog.set('account', accountReblog);
      } else {
        statusReblog = null;
      }

      let filtered = false;
      let mediaFiltered = false;
      if ((accountReblog || accountBase).get('id') !== me && filters) {
        let filterResults = statusReblog?.get('filtered') || statusBase.get('filtered') || ImmutableList();
        if (!warnInsteadOfHide && filterResults.some((result) => filters.getIn([result.get('filter'), 'filter_action']) === 'hide')) {
          return null;
        }

        let mediaFilters = filterResults.filter(result => filters.getIn([result.get('filter'), 'filter_action']) === 'blur');
        if (!mediaFilters.isEmpty()) {
          mediaFiltered = mediaFilters.map(result => filters.getIn([result.get('filter'), 'title']));
        }

        filterResults = filterResults.filter(result => filters.has(result.get('filter')) && filters.getIn([result.get('filter'), 'filter_action']) !== 'blur');
        if (!filterResults.isEmpty()) {
          filtered = filterResults.map(result => filters.getIn([result.get('filter'), 'title']));
        }
      }

      return statusBase.withMutations(map => {
        map.set('reblog', statusReblog);
        map.set('account', accountBase);
        map.set('matched_filters', filtered);
        map.set('matched_media_filters', mediaFiltered);
      });
    },
  );
};

export const makeGetPictureInPicture = () => {
  return createSelector([
    (state, { id }) => state.picture_in_picture.statusId === id,
    (state) => state.getIn(['meta', 'layout']) !== 'mobile',
  ], (inUse, available) => ImmutableMap({
    inUse: inUse && available,
    available,
  }));
};

export const makeGetNotification = () => createSelector([
  (_, base)             => base,
  (state, _, accountId) => state.getIn(['accounts', accountId]),
], (base, account) => base.set('account', account));

export const makeGetReport = () => createSelector([
  (_, base) => base,
  (state, _, targetAccountId) => state.getIn(['accounts', targetAccountId]),
], (base, targetAccount) => base.set('target_account', targetAccount));

export const getStatusList = createSelector([
  (state, type) => state.getIn(['status_lists', type, 'items']),
], (items) => items.toList());
