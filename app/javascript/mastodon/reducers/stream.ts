import protooClient from "protoo-client";
import { createGlobalState } from "react-hooks-global-state";
import { Map as ImmutableMap, fromJS } from 'immutable';

export type Streaming = {
  roomId: string;
};

export type StreamState = typeof initialState

function Undefined<T>(): undefined | T {
  return undefined;
}

type Stream = {
  media: MediaStream | undefined,
  subscribers: number
}

const initialState = {
  activeStreaming: Undefined<Streaming>(),
  protooClient: Undefined<protooClient.Peer>(),
  webcam: Undefined<MediaStream>(),
  streams: ImmutableMap<string, Stream>()
};
const streamStore_ = createGlobalState(initialState)

export const streamStore = {
  ...streamStore_, 
  getState(): StreamState {
    //@ts-ignore
    return streamStore_.getState();
  },
  setState(state: StreamState) {
    //@ts-ignore
    streamStore_.setState(state);
  },
};

export default streamStore;
