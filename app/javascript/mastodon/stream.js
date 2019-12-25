import WebSocketClient from '@gamestdio/websocket';

const randomIntUpTo = max => Math.floor(Math.random() * Math.floor(max));

export function connectStream(path, pollingRefresh = null, callbacks = () => ({ onConnect() {}, onDisconnect() {}, onReceive() {} })) {
  return (dispatch, getState) => {
    const streamingAPIBaseURL = getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = getState().getIn(['meta', 'access_token']);
    const { onConnect, onDisconnect, onReceive } = callbacks(dispatch, getState);

    let polling = null;

    const setupPolling = () => {
      pollingRefresh(dispatch, () => {
        polling = setTimeout(() => setupPolling(), 20000 + randomIntUpTo(20000));
      });
    };

    const clearPolling = () => {
      if (polling) {
        clearTimeout(polling);
        polling = null;
      }
    };

    const subscription = getStream(streamingAPIBaseURL, accessToken, path, {
      connected () {
        if (pollingRefresh) {
          clearPolling();
        }

        onConnect();
      },

      disconnected () {
        if (pollingRefresh) {
          polling = setTimeout(() => setupPolling(), randomIntUpTo(40000));
        }

        onDisconnect();
      },

      received (data) {
        onReceive(data);
      },

      reconnected () {
        if (pollingRefresh) {
          clearPolling();
          pollingRefresh(dispatch);
        }

        onConnect();
      },

    });

    const disconnect = () => {
      if (subscription) {
        subscription.close();
      }

      clearPolling();
    };

    return disconnect;
  };
}


export default function getStream(streamingAPIBaseURL, accessToken, stream, { connected, received, disconnected, reconnected }) {
  const params = [ `stream=${stream}` ];

  const ws = new WebSocketClient(`${streamingAPIBaseURL}/api/v1/streaming/?${params.join('&')}`, accessToken);

  ws.onopen      = connected;
  ws.onmessage   = e => received(JSON.parse(e.data));
  ws.onclose     = disconnected;
  ws.onreconnect = reconnected;

  return ws;
};
