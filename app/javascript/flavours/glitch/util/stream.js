import WebSocketClient from 'websocket.js';

export function connectStream(path, pollingRefresh = null, callbacks = () => ({ onConnect() {}, onDisconnect() {}, onReceive() {} })) {
  return (dispatch, getState) => {
    const streamingAPIBaseURL = getState().getIn(['meta', 'streaming_api_base_url']);
    const accessToken = getState().getIn(['meta', 'access_token']);
    const { onConnect, onDisconnect, onReceive } = callbacks(dispatch, getState);
    let polling = null;

    const setupPolling = () => {
      polling = setInterval(() => {
        pollingRefresh(dispatch);
      }, 20000);
    };

    const clearPolling = () => {
      if (polling) {
        clearInterval(polling);
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
          setupPolling();
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

  if (accessToken !== null) {
    params.push(`access_token=${accessToken}`);
  }

  const ws = new WebSocketClient(`${streamingAPIBaseURL}/api/v1/streaming/?${params.join('&')}`);

  ws.onopen      = connected;
  ws.onmessage   = e => received(JSON.parse(e.data));
  ws.onclose     = disconnected;
  ws.onreconnect = reconnected;

  return ws;
};
