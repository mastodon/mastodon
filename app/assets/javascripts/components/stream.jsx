import WebSocketClient from 'websocket.js';

const createWebSocketURL = (url) => {
  const a = document.createElement('a');

  a.href     = url;
  a.href     = a.href;
  a.protocol = a.protocol.replace('http', 'ws');

  return a.href;
};

export default function getStream(accessToken, stream, { connected, received, disconnected }) {
  const ws = new WebSocketClient(`${createWebSocketURL(STREAMING_API_BASE_URL)}/api/v1/streaming/?access_token=${accessToken}&stream=${stream}`);

  ws.onopen    = connected;
  ws.onmessage = e => received(JSON.parse(e.data));
  ws.onclose   = disconnected;

  return ws;
};
