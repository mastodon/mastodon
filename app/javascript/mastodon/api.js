// @ts-check

import axios from 'axios';
import LinkHeader from 'http-link-header';
import ready from './ready';

/**
 * @param {import('axios').AxiosResponse} response
 * @returns {LinkHeader}
 */
export const getLinks = response => {
  const value = response.headers.link;

  if (!value) {
    return new LinkHeader();
  }

  return LinkHeader.parse(value);
};

/** @type {import('axios').RawAxiosRequestHeaders} */
const csrfHeader = {};

/**
 * @returns {void}
 */
const setCSRFHeader = () => {
  /** @type {HTMLMetaElement | null} */
  const csrfToken = document.querySelector('meta[name=csrf-token]');

  if (csrfToken) {
    csrfHeader['X-CSRF-Token'] = csrfToken.content;
  }
};

ready(setCSRFHeader);

/**
 * @param {() => import('immutable').Map<string,any>} getState
 * @returns {import('axios').RawAxiosRequestHeaders}
 */
const authorizationHeaderFromState = getState => {
  const accessToken = getState && getState().getIn(['meta', 'access_token'], '');

  if (!accessToken) {
    return {};
  }

  return {
    'Authorization': `Bearer ${accessToken}`,
  };
};

/**
 * @param {() => import('immutable').Map<string,any>} getState
 * @returns {import('axios').AxiosInstance}
 */
export default function api(getState) {
  return axios.create({
    headers: {
      ...csrfHeader,
      ...authorizationHeaderFromState(getState),
    },

    transformResponse: [
      function (data) {
        try {
          return JSON.parse(data);
        } catch {
          return data;
        }
      },
    ],
  });
}
