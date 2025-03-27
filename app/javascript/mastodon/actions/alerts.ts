import { defineMessages } from 'react-intl';

import { createAction } from '@reduxjs/toolkit';

import { AxiosError } from 'axios';
import type { AxiosResponse } from 'axios';

import type { Alert } from 'mastodon/models/alert';

interface ApiErrorResponse {
  error?: string;
}

const messages = defineMessages({
  unexpectedTitle: { id: 'alert.unexpected.title', defaultMessage: 'Oops!' },
  unexpectedMessage: {
    id: 'alert.unexpected.message',
    defaultMessage: 'An unexpected error occurred.',
  },
  rateLimitedTitle: {
    id: 'alert.rate_limited.title',
    defaultMessage: 'Rate limited',
  },
  rateLimitedMessage: {
    id: 'alert.rate_limited.message',
    defaultMessage: 'Please retry after {retry_time, time, medium}.',
  },
});

export const dismissAlert = createAction<{ key: number }>('alerts/dismiss');

export const clearAlerts = createAction('alerts/clear');

export const showAlert = createAction<Omit<Alert, 'key'>>('alerts/show');

const ignoreAlert = createAction('alerts/ignore');

export const showAlertForError = (error: unknown, skipNotFound = false) => {
  if (error instanceof AxiosError && error.response) {
    const { status, statusText, headers } = error.response;
    const { data } = error.response as AxiosResponse<ApiErrorResponse>;

    // Skip these errors as they are reflected in the UI
    if (skipNotFound && (status === 404 || status === 410)) {
      return ignoreAlert();
    }

    // Rate limit errors
    if (status === 429 && headers['x-ratelimit-reset']) {
      return showAlert({
        title: messages.rateLimitedTitle,
        message: messages.rateLimitedMessage,
        values: {
          retry_time: new Date(headers['x-ratelimit-reset'] as string),
        },
      });
    }

    return showAlert({
      title: `${status}`,
      message: data.error ?? statusText,
    });
  }

  // An aborted request, e.g. due to reloading the browser window, is not really an error
  if (error instanceof AxiosError && error.code === AxiosError.ECONNABORTED) {
    return ignoreAlert();
  }

  console.error(error);

  return showAlert({
    title: messages.unexpectedTitle,
    message: messages.unexpectedMessage,
  });
};
