import type { AxiosResponse, RawAxiosRequestHeaders } from 'axios';
import axios from 'axios';
import LinkHeader from 'http-link-header';

import { getAccessToken } from './initial_state';
import ready from './ready';

export const getLinks = (response: AxiosResponse) => {
  const value = response.headers.link as string | undefined;

  if (!value) {
    return new LinkHeader();
  }

  return LinkHeader.parse(value);
};

const csrfHeader: RawAxiosRequestHeaders = {};

const setCSRFHeader = () => {
  const csrfToken = document.querySelector<HTMLMetaElement>(
    'meta[name=csrf-token]',
  );

  if (csrfToken) {
    csrfHeader['X-CSRF-Token'] = csrfToken.content;
  }
};

void ready(setCSRFHeader);

const authorizationTokenFromInitialState = (): RawAxiosRequestHeaders => {
  const accessToken = getAccessToken();

  if (!accessToken) return {};

  return {
    Authorization: `Bearer ${accessToken}`,
  };
};

// eslint-disable-next-line import/no-default-export
export default function api() {
  return axios.create({
    headers: {
      ...csrfHeader,
      ...authorizationTokenFromInitialState(),
    },

    transformResponse: [
      function (data: unknown) {
        try {
          return JSON.parse(data as string) as unknown;
        } catch {
          return data;
        }
      },
    ],
  });
}
