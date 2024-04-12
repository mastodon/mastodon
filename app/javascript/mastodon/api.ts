import type { AxiosResponse, RawAxiosRequestHeaders } from 'axios';
import axios from 'axios';
import LinkHeader from 'http-link-header';

import ready from './ready';
import type { GetState } from './store';

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

export const authorizationTokenFromState = (getState?: GetState) => {
  return (
    getState && (getState().meta.get('access_token', '') as string | false)
  );
};

const authorizationHeaderFromState = (getState?: GetState) => {
  const accessToken = authorizationTokenFromState(getState);

  if (!accessToken) {
    return {};
  }

  return {
    Authorization: `Bearer ${accessToken}`,
  } as RawAxiosRequestHeaders;
};

// eslint-disable-next-line import/no-default-export
export default function api(getState: GetState) {
  return axios.create({
    headers: {
      ...csrfHeader,
      ...authorizationHeaderFromState(getState),
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
