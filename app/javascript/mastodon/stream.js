// @ts-check

import WebSocketClient from '@gamestdio/websocket';

import { getAccessToken } from './initial_state';

/**
 * @type {WebSocketClient | undefined}
 */
let sharedConnection;

/**
 * @typedef Subscription
 * @property {string} channelName
 * @property {Object.<string, string>} params
 * @property {function(): void} onConnect
 * @property {function(StreamEvent): void} onReceive
 * @property {function(): void} onDisconnect
 */

/**
 * @typedef StreamEvent
 * @property {string} event
 * @property {object} payload
 */

/**
 * @type {Array.<Subscription>}
 */
const subscriptions = [];

/**
 * @type {Object.<string, number>}
 */
const subscriptionCounters = {};

/**
 * @param {Subscription} subscription
 */
const addSubscription = subscription => {
  subscriptions.push(subscription);
};

/**
 * @param {Subscription} subscription
 */
const removeSubscription = subscription => {
  const index = subscriptions.indexOf(subscription);

  if (index !== -1) {
    subscriptions.splice(index, 1);
  }
};

/**
 * @param {Subscription} subscription
 */
const subscribe = ({ channelName, params, onConnect }) => {
  const key = channelNameWithInlineParams(channelName, params);

  subscriptionCounters[key] = subscriptionCounters[key] || 0;

  if (subscriptionCounters[key] === 0) {
    // @ts-expect-error
    sharedConnection.send(JSON.stringify({ type: 'subscribe', stream: channelName, ...params }));
  }

  subscriptionCounters[key] += 1;
  onConnect();
};

/**
 * @param {Subscription} subscription
 */
const unsubscribe = ({ channelName, params, onDisconnect }) => {
  const key = channelNameWithInlineParams(channelName, params);

  subscriptionCounters[key] = subscriptionCounters[key] || 1;

  // @ts-expect-error
  if (subscriptionCounters[key] === 1 && sharedConnection.readyState === WebSocketClient.OPEN) {
    // @ts-expect-error
    sharedConnection.send(JSON.stringify({ type: 'unsubscribe', stream: channelName, ...params }));
  }

  subscriptionCounters[key] -= 1;
  onDisconnect();
};

const sharedCallbacks = {
  connected() {
    subscriptions.forEach(subscription => subscribe(subscription));
  },

  // @ts-expect-error
  received(data) {
    const { stream } = data;

    subscriptions.filter(({ channelName, params }) => {
      const streamChannelName = stream[0];

      if (stream.length === 1) {
        return channelName === streamChannelName;
      }

      const streamIdentifier = stream[1];

      if (['hashtag', 'hashtag:local'].includes(channelName)) {
        return channelName === streamChannelName && params.tag === streamIdentifier;
      } else if (channelName === 'list') {
        return channelName === streamChannelName && params.list === streamIdentifier;
      }

      return false;
    }).forEach(subscription => {
      subscription.onReceive(data);
    });
  },

  disconnected() {
    subscriptions.forEach(subscription => unsubscribe(subscription));
  },

  reconnected() {
  },
};

/**
 * @param {string} channelName
 * @param {Object.<string, string>} params
 * @returns {string}
 */
const channelNameWithInlineParams = (channelName, params) => {
  if (Object.keys(params).length === 0) {
    return channelName;
  }

  return `${channelName}&${Object.keys(params).map(key => `${key}=${params[key]}`).join('&')}`;
};

/**
 * @param {string} channelName
 * @param {Object.<string, string>} params
 * @param {function(Function, Function): { onConnect: (function(): void), onReceive: (function(StreamEvent): void), onDisconnect: (function(): void) }} callbacks
 * @returns {function(): void}
 */
// @ts-expect-error
export const connectStream = (channelName, params, callbacks) => (dispatch, getState) => {
  const streamingAPIBaseURL = getState().getIn(['meta', 'streaming_api_base_url']);
  const accessToken = getAccessToken();
  const { onConnect, onReceive, onDisconnect } = callbacks(dispatch, getState);

  if(!accessToken) throw new Error("Trying to connect to the streaming server but no access token is available.");

  // If we cannot use a websockets connection, we must fall back
  // to using individual connections for each channel
  if (!streamingAPIBaseURL.startsWith('ws')) {
    const connection = createConnection(streamingAPIBaseURL, accessToken, channelNameWithInlineParams(channelName, params), {
      connected() {
        onConnect();
      },

      received(data) {
        onReceive(data);
      },

      disconnected() {
        onDisconnect();
      },

      reconnected() {
        onConnect();
      },
    });

    return () => {
      connection.close();
    };
  }

  const subscription = {
    channelName,
    params,
    onConnect,
    onReceive,
    onDisconnect,
  };

  addSubscription(subscription);

  // If a connection is open, we can execute the subscription right now. Otherwise,
  // because we have already registered it, it will be executed on connect

  if (!sharedConnection) {
    sharedConnection = /** @type {WebSocketClient} */ (createConnection(streamingAPIBaseURL, accessToken, '', sharedCallbacks));
  } else if (sharedConnection.readyState === WebSocketClient.OPEN) {
    subscribe(subscription);
  }

  return () => {
    removeSubscription(subscription);
    unsubscribe(subscription);
  };
};

const KNOWN_EVENT_TYPES = [
  'update',
  'delete',
  'notification',
  'conversation',
  'filters_changed',
  'announcement',
  'announcement.delete',
  'announcement.reaction',
];

/**
 * @param {MessageEvent} e
 * @param {function(StreamEvent): void} received
 */
const handleEventSourceMessage = (e, received) => {
  received({
    event: e.type,
    payload: e.data,
  });
};

/**
 * @param {string} streamingAPIBaseURL
 * @param {string} accessToken
 * @param {string} channelName
 * @param {{ connected: Function, received: function(StreamEvent): void, disconnected: Function, reconnected: Function }} callbacks
 * @returns {WebSocketClient | EventSource}
 */
const createConnection = (streamingAPIBaseURL, accessToken, channelName, { connected, received, disconnected, reconnected }) => {
  const params = channelName.split('&');

  // @ts-expect-error
  channelName = params.shift();

  if (streamingAPIBaseURL.startsWith('ws')) {
    // @ts-expect-error
    const ws = new WebSocketClient(`${streamingAPIBaseURL}/api/v1/streaming/?${params.join('&')}`, accessToken);

    // @ts-expect-error
    ws.onopen = connected;
    ws.onmessage = e => received(JSON.parse(e.data));
    // @ts-expect-error
    ws.onclose = disconnected;
    // @ts-expect-error
    ws.onreconnect = reconnected;

    return ws;
  }

  channelName = channelName.replace(/:/g, '/');

  if (channelName.endsWith(':media')) {
    channelName = channelName.replace('/media', '');
    params.push('only_media=true');
  }

  params.push(`access_token=${accessToken}`);

  const es = new EventSource(`${streamingAPIBaseURL}/api/v1/streaming/${channelName}?${params.join('&')}`);

  es.onopen = () => {
    connected();
  };

  KNOWN_EVENT_TYPES.forEach(type => {
    es.addEventListener(type, e => handleEventSourceMessage(/** @type {MessageEvent} */(e), received));
  });

  es.onerror = /** @type {function(): void} */ (disconnected);

  return es;
};
