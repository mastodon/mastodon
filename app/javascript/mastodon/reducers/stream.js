import { createGlobalState } from 'react-hooks-global-state';

const initialState = {
  videoTrack: new MediaStream,
  activePreview: false,
};

const streamStore = createGlobalState( initialState );
export default streamStore;
