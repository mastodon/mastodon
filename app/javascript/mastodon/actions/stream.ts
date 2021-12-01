import {
  getProtooClient,
  getSendTransport,
} from "../features/stream/mediasoupStreamingService";
import streamStore from "../reducers/stream";
import * as mediasoupApi from "../features/stream/mediasoupApi";

export const startStreaming = async () => {
  const state = streamStore.getState();

  const sendTransport = await getSendTransport();

  sendTransport.on(
    "connect",
    (
      { dtlsParameters },
      callback,
      errback // eslint-disable-line no-shadow
    ) => {
      mediasoupApi
        .connectBroadcasterTransport(
          {
            room: "streaming",
            broadcaster: "streamer",
            transport: sendTransport.id,
          },
          { dtlsParameters }
        )
        .then(callback)
        .catch(errback);
    }
  );

  sendTransport.on(
    "produce",
    async ({ kind, rtpParameters, appData }, callback, errback) => {
      try {
        // eslint-disable-next-line no-shadow
        const { id } = await mediasoupApi.createMediasoupProducer(
          {
            broadcasterId: "streamer",
            roomId: "streaming",
            transportId: sendTransport.id,
          },
          {
            transportId: sendTransport.id,
            kind,
            rtpParameters,
            appData,
          } as any
        );

        callback({ id });
      } catch (error) {
        errback(error);
      }
    }
  );
  // const res = await mediasoupClient.createMediaTransport(
  //   { broadcaster: "streamer", roomId: "streaming" },
  //   {
  //     comedia: true,
  //     rtcpMux: false,
  //     type: "plain",
  //   }
  // );

  // const client = getProtooClient("streaming");

  sendTransport.produce({
    track: state.webcam,
  });

  streamStore.setState({
    ...state,
    sendTransport,
  });
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
