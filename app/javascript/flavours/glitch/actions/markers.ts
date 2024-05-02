import { List as ImmutableList } from 'immutable';

import { debounce } from 'lodash';

import type { MarkerJSON } from 'flavours/glitch/api_types/markers';
import type { RootState } from 'flavours/glitch/store';
import { createAppAsyncThunk } from 'flavours/glitch/store/typed_functions';

import api, { authorizationTokenFromState } from '../api';
import { compareId } from '../compare_id';

export const synchronouslySubmitMarkers = createAppAsyncThunk(
  'markers/submit',
  async (_args, { getState }) => {
    const accessToken = authorizationTokenFromState(getState);
    const params = buildPostMarkersParams(getState());

    if (Object.keys(params).length === 0 || !accessToken) {
      return;
    }

    // The Fetch API allows us to perform requests that will be carried out
    // after the page closes. But that only works if the `keepalive` attribute
    // is supported.
    if ('fetch' in window && 'keepalive' in new Request('')) {
      await fetch('/api/v1/markers', {
        keepalive: true,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(params),
      });

      return;
      // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
    } else if ('navigator' && 'sendBeacon' in navigator) {
      // Failing that, we can use sendBeacon, but we have to encode the data as
      // FormData for DoorKeeper to recognize the token.
      const formData = new FormData();

      formData.append('bearer_token', accessToken);

      for (const [id, value] of Object.entries(params)) {
        if (value.last_read_id)
          formData.append(`${id}[last_read_id]`, value.last_read_id);
      }

      if (navigator.sendBeacon('/api/v1/markers', formData)) {
        return;
      }
    }

    // If neither Fetch nor sendBeacon worked, try to perform a synchronous
    // request.
    try {
      const client = new XMLHttpRequest();

      client.open('POST', '/api/v1/markers', false);
      client.setRequestHeader('Content-Type', 'application/json');
      client.setRequestHeader('Authorization', `Bearer ${accessToken}`);
      client.send(JSON.stringify(params));
    } catch (e) {
      // Do not make the BeforeUnload handler error out
    }
  },
);

interface MarkerParam {
  last_read_id?: string;
}

function getLastHomeId(state: RootState): string | undefined {
  /* eslint-disable @typescript-eslint/no-unsafe-return, @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
  return (
    state
      // @ts-expect-error state.timelines is not yet typed
      .getIn(['timelines', 'home', 'items'], ImmutableList())
      // @ts-expect-error state.timelines is not yet typed
      .find((item) => item !== null)
  );
}

function getLastNotificationId(state: RootState): string | undefined {
  // @ts-expect-error state.notifications is not yet typed
  return state.getIn(['notifications', 'lastReadId']);
}

const buildPostMarkersParams = (state: RootState) => {
  const params = {} as { home?: MarkerParam; notifications?: MarkerParam };

  const lastHomeId = getLastHomeId(state);
  const lastNotificationId = getLastNotificationId(state);

  if (lastHomeId && compareId(lastHomeId, state.markers.home) > 0) {
    params.home = {
      last_read_id: lastHomeId,
    };
  }

  if (
    lastNotificationId &&
    lastNotificationId !== '0' &&
    compareId(lastNotificationId, state.markers.notifications) > 0
  ) {
    params.notifications = {
      last_read_id: lastNotificationId,
    };
  }

  return params;
};

export const submitMarkersAction = createAppAsyncThunk<{
  home: string | undefined;
  notifications: string | undefined;
}>('markers/submitAction', async (_args, { getState }) => {
  const accessToken = authorizationTokenFromState(getState);
  const params = buildPostMarkersParams(getState());

  if (Object.keys(params).length === 0 || accessToken === '') {
    return { home: undefined, notifications: undefined };
  }

  await api(getState).post<MarkerJSON>('/api/v1/markers', params);

  return {
    home: params.home?.last_read_id,
    notifications: params.notifications?.last_read_id,
  };
});

const debouncedSubmitMarkers = debounce(
  (dispatch) => {
    dispatch(submitMarkersAction());
  },
  300000,
  {
    leading: true,
    trailing: true,
  },
);

export const submitMarkers = createAppAsyncThunk(
  'markers/submit',
  (params: { immediate?: boolean }, { dispatch }) => {
    debouncedSubmitMarkers(dispatch);

    if (params.immediate) {
      debouncedSubmitMarkers.flush();
    }
  },
);

export const fetchMarkers = createAppAsyncThunk(
  'markers/fetch',
  async (_args, { getState }) => {
    const response = await api(getState).get<Record<string, MarkerJSON>>(
      `/api/v1/markers`,
      { params: { timeline: ['notifications'] } },
    );

    return { markers: response.data };
  },
);
