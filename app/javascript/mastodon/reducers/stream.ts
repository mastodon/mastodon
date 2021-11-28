import protooClient from 'protoo-client';
import mediasoupClient from 'mediasoup-client';
import { createGlobalState } from 'react-hooks-global-state';

export type Streaming = {
  roomId: string;
};

export type StreamState = {
  activeStreaming: Streaming | undefined;
  protooClient: protooClient.Peer | undefined;
  sendTransport: mediasoupClient.types.Transport | undefined;
  webcam: MediaStreamTrack | undefined;
};

const initialState: StreamState = {
  activeStreaming: undefined,
  protooClient: undefined,
  sendTransport: undefined,
  webcam: undefined,
};

export const streamStore = createGlobalState(initialState);


export default {
  ...streamStore,
  getState(): StreamState {
    //@ts-ignore
    return streamStore.getState();
  },
  setState(state: StreamState) {
    //@ts-ignore
    streamStore.setState(state);
  },
};
