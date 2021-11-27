import { createGlobalState } from 'react-hooks-global-state';

const initialState = {
  videoTrack: new MediaStream,
  activePreview: false,
  activeStreaming: null,
};

const streamStore = createGlobalState( initialState );

export default streamStore;
