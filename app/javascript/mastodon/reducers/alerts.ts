import { createReducer } from '@reduxjs/toolkit';

import { isEqual } from 'lodash';

import { showAlert, dismissAlert, clearAlerts } from 'mastodon/actions/alerts';
import type { Alert } from 'mastodon/models/alert';

const initialState: Alert[] = [];

let id = 0;

export const alertsReducer = createReducer(initialState, (builder) => {
  builder
    .addCase(showAlert, (state, { payload }) => {
      const existing = state.find(
        (item) =>
          isEqual(item.title, payload.title) &&
          isEqual(item.message, payload.message),
      );

      if (existing) {
        existing.values = payload.values;
        return;
      }

      state.push({
        key: id++,
        ...payload,
      });
    })
    .addCase(dismissAlert, (state, { payload: { key } }) => {
      return state.filter((item) => item.key !== key);
    })
    .addCase(clearAlerts, () => {
      return [];
    });
});
