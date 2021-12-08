import { useEffect, useMemo, useRef } from "react";
import streamStore from "../reducers/stream";
import { publishStream } from "../features/stream/mediasoupPublisherService";
import {
  startStream,
  subscribeChannel,
} from "../features/stream/mediasoupStreamingService";
import { functionResultWrapper } from "../utils/fp";
import randomString from 'random-string'

export const startStreaming = (): string => {
  const state = streamStore.getState();

  // const sendTransport = await getSendTransport();

  // sendTransport.on(
  //   "connect",
  //   (
  //     { dtlsParameters },
  //     callback,
  //     errback // eslint-disable-line no-shadow
  //   ) => {
  //     mediasoupApi
  //       .connectBroadcasterTransport(
  //         {
  //           room: "streaming",
  //           broadcaster: "streamer",
  //           transport: sendTransport.id,
  //         },
  //         { dtlsParameters }
  //       )
  //       .then(callback)
  //       .catch(errback);
  //   }
  // );

  // sendTransport.on(
  //   "produce",
  //   async ({ kind, rtpParameters, appData }, callback, errback) => {
  //     try {
  //       // eslint-disable-next-line no-shadow
  //       const { id } = await mediasoupApi.createMediasoupProducer(
  //         {
  //           broadcasterId: "streamer",
  //           roomId: "streaming",
  //           transportId: sendTransport.id,
  //         },
  //         {
  //           transportId: sendTransport.id,
  //           kind,
  //           rtpParameters,
  //           appData,
  //         } as any
  //       );

  //       callback({ id });
  //     } catch (error) {
  //       errback(error);
  //     }
  //   }
  // );
  // // const res = await mediasoupClient.createMediaTransport(
  // //   { broadcaster: "streamer", roomId: "streaming" },
  // //   {
  // //     comedia: true,
  // //     rtcpMux: false,
  // //     type: "plain",
  // //   }
  // // );

  // // const client = getProtooClient("streaming");
  const m = new MediaStream();
  m.addTrack(state.webcam);

  const id = randomString({length: 15})
  publishStream({id, sendStream: m});

  // sendTransport.produce({
  //   track: state.webcam,
  // });

  // streamStore.setState({
  //   ...state,
  //   sendTransport,
  // });
  return id
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

type x = {
  [x in "s" | "w"]: any;
};

function curry<FN extends (...args: any) => any>(func: FN) {
  return function curried(args: Parameters<FN>) {
    if (args.length >= func.length) {
      return func(args);
    } else {
      return function (...args2: any[]) {
        return curried.apply(this, args.concat(args2));
      };
    }
  };
}

const curriedSetGlobalState = curry(streamStore.setGlobalState);

// curriedSetGlobalState(['streams'])
const withPrev = (data: object) => (prev: any) => ({ ...prev, ...data });

export function subscribeStream({ id }: { id: string }) {
  const stream = streamStore.getGlobalState("streams").get(id) ?? {
    media: undefined,
    subscribers: 0,
  };

  function save<K extends keyof typeof stream>(
    item: K,
    value: typeof stream[K]
  ) {
    streamStore.setGlobalState("streams", (p) => {
      const new_val = p.set(id, { ...p.get(id), [item]: value });
      return new_val;
    });
  }

  function subscribe() {
    stream.subscribers++;
    save("subscribers", stream.subscribers);
  }

  function unSubscribe() {
    stream.subscribers--;
    save("subscribers", stream.subscribers);
  }

  if (stream.subscribers === 0) {
    subscribeChannel(id, (p, t) => {
      startStream(p, t, {
        onStreamChange: (s) => {
          console.log("NEW PEER");
          stream.media = s;
          save("media", s);
        },
        onClose: () => {
          console.log("CLOSE");
          save("media", undefined);
        },
      });
    });
  }
  subscribe();

  return unSubscribe;
}
export function useSubscribeStream({
  id,
}: {
  id: string;
}): MediaStream | undefined {
  useEffect(() => {
    return subscribeStream({ id });
  }, [id]);

  const [streams] = streamStore.useGlobalState("streams");

  const stream = useMemo(
    function getStream() {
      const stream = streams.get(id)?.media;
      console.log("memo", { streams, id, stream });
      return stream;
    },
    [streams]
  );

  console.log({ streams, stream });

  return stream;
}

export function useMediaStreamToVideoRef({
  stream,
}: {
  stream: MediaStream | undefined;
}) {
  const videoRef = useRef<HTMLVideoElement>();
  useEffect(
    function showStream() {
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
      }
    },
    [stream]
  );

  return videoRef;
}

export const useMediaStreamToVideoRefAndPlay = functionResultWrapper(
  useMediaStreamToVideoRef
)((ref) => {
  ref.current?.play();
  return ref;
});
// export const stopStreaming = () => {
//   const [currentStream, setCurrentStream] =
//     streamStore.useGlobalState("activeStreaming");
//   if (currentStream) {
//     currentStream.stop();
//     setCurrentStream(null);
//   }
// };
