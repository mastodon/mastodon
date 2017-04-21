import WebSocketClient from 'websocket.js';

const createWebSocketURL = (url) => {
  const a = document.createElement('a');

  a.href     = url;
  a.href     = a.href;
  a.protocol = a.protocol.replace('http', 'ws');

  return a.href;
};

export default function getStream(streamingAPIBaseURL, accessToken, stream, { connected, received, disconnected, reconnected }) {
  const ws = new WebSocketClient(`${createWebSocketURL(streamingAPIBaseURL)}/api/v1/streaming/?access_token=${accessToken}&stream=${stream}`);

  ws.onopen      = connected;
  ws.onmessage   = e => received(JSON.parse(e.data));
  ws.onclose     = disconnected;
  ws.onreconnect = reconnected;

  return ws;
};
