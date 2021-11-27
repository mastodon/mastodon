import { mediasoupStreamingService } from '../features/stream/mediasoupStreamingService';
import streamStore from '../reducers/stream';

export const startStreaming = async () => {
  const [, setCurrentStream] = streamStore.useGlobalState('activeStreaming');
  const newStreaming = mediasoupStreamingService((newState) =>
    setCurrentStream(newState),
  );

  const room = await newStreaming.createRoom();
  return room;
};

export const stopStreaming = () => {
  const [currentStream, setCurrentStream] =
    streamStore.useGlobalState('activeStreaming');
  if (currentStream) {
    currentStream.stop();
    setCurrentStream(null);
  }
};
