import type {
  AxiosError,
  AxiosResponse,
  Method,
  RawAxiosRequestHeaders,
} from 'axios';
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

export interface AsyncRefreshHeader {
  id: string;
  retry: number;
}

const isAsyncRefreshHeader = (obj: object): obj is AsyncRefreshHeader =>
  'id' in obj && 'retry' in obj;

export const getAsyncRefreshHeader = (
  response: AxiosResponse,
): AsyncRefreshHeader | null => {
  const value = response.headers['mastodon-async-refresh'] as
    | string
    | undefined;

  if (!value) {
    return null;
  }

  const asyncRefreshHeader: Record<string, unknown> = {};

  value.split(/,\s*/).forEach((pair) => {
    const [key, val] = pair.split('=', 2);

    let typedValue: string | number;

    if (key && ['id', 'retry'].includes(key) && val) {
      if (val.startsWith('"')) {
        typedValue = val.slice(1, -1);
      } else {
        typedValue = parseInt(val);
      }

      asyncRefreshHeader[key] = typedValue;
    }
  });

  if (isAsyncRefreshHeader(asyncRefreshHeader)) {
    return asyncRefreshHeader;
  }

  return null;
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
export default function api(withAuthorization = true) {
  const instance = axios.create({
    transitional: {
      clarifyTimeoutError: true,
    },
    headers: {
      ...csrfHeader,
      ...(withAuthorization ? authorizationTokenFromInitialState() : {}),
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

  instance.interceptors.response.use(
    (response: AxiosResponse) => {
      if (response.headers.deprecation) {
        console.warn(
          `Deprecated request: ${response.config.method} ${response.config.url}`,
        );
      }
      return response;
    },
    (error: AxiosError) => {
      return Promise.reject(error);
    },
  );

  return instance;
}

type ApiUrl = `v${1 | '1_alpha' | 2}/${string}`;
type RequestParamsOrData<T = unknown> = T | Record<string, unknown>;

export async function apiRequest<
  ApiResponse = unknown,
  ApiParamsOrData = unknown,
>(
  method: Method,
  url: string,
  args: {
    signal?: AbortSignal;
    params?: RequestParamsOrData<ApiParamsOrData>;
    data?: RequestParamsOrData<ApiParamsOrData>;
    timeout?: number;
  } = {},
) {
  const { data } = await api().request<ApiResponse>({
    method,
    url: '/api/' + url,
    ...args,
  });

  return data;
}

export async function apiRequestGet<ApiResponse = unknown, ApiParams = unknown>(
  url: ApiUrl,
  params?: RequestParamsOrData<ApiParams>,
) {
  return apiRequest<ApiResponse>('GET', url, { params });
}

export async function apiRequestPost<ApiResponse = unknown, ApiData = unknown>(
  url: ApiUrl,
  data?: RequestParamsOrData<ApiData>,
) {
  return apiRequest<ApiResponse>('POST', url, { data });
}

export async function apiRequestPut<ApiResponse = unknown, ApiData = unknown>(
  url: ApiUrl,
  data?: RequestParamsOrData<ApiData>,
) {
  return apiRequest<ApiResponse>('PUT', url, { data });
}

export async function apiRequestDelete<
  ApiResponse = unknown,
  ApiParams = unknown,
>(url: ApiUrl, params?: RequestParamsOrData<ApiParams>) {
  return apiRequest<ApiResponse>('DELETE', url, { params });
}
