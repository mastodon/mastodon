import {
  getProtooClient,
  getSendTransport,
} from "../features/stream/mediasoupStreamingService";
import streamStore from "../reducers/stream";

export const startStreaming = async () => {
  const state = streamStore.getState();
  const client = getProtooClient('streaming');
  client.on('open', async () => {
    console.log("start streaming")
    const sendTransport = await getSendTransport(client);
  
    sendTransport.produce({
      track: state.webcam,
    });
  
    streamStore.setState({
      ...state,
      protooClient: client,
      sendTransport,
    });
  })
};

export function selectWebcam() {
  navigator.mediaDevices
    .getUserMedia({ video: true })
    .then((stream) => {
      const videoTrack_ = stream.getVideoTracks()[0];
      streamStore.setGlobalState("webcam", (p) => {
        p?.stop();
        return videoTrack_;
      });

      videoTrack_.addEventListener("ended", () => {
        streamStore.setGlobalState("webcam", undefined);
      });
    })
    .catch(undefined);
}

export function turnOffWebcam() {
  streamStore.getGlobalState("webcam")?.stop();
  streamStore.setGlobalState("webcam", undefined);
}
// export const stopStreaming = () => {
//   const [currentStream, setCurrentStream] =
//     streamStore.useGlobalState("activeStreaming");
//   if (currentStream) {
//     currentStream.stop();
//     setCurrentStream(null);
//   }
// };
