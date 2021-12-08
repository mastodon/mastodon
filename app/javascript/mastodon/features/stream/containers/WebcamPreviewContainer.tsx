import { pipe } from "fp-ts/lib/function";
import React, { useMemo } from "react";
import {
  useMediaStreamToVideoRefAndPlay
} from "../../../actions/stream";
import streamStore from "../../../reducers/stream";
import { injectHook } from "../../../utils/fp";

const useWebcamToMediaStream = () => {
  const [webcam] = streamStore.useGlobalState("webcam");
  return useMemo(
    function getWebcamStream() {
      if (webcam) {
        const mediaStream = new MediaStream();
        mediaStream.addTrack(webcam);
        return mediaStream;
      }
    },
    [webcam]
  );
};

const StreamPreviewContainer = pipe(
  (p: { ref: React.MutableRefObject<HTMLVideoElement> }) => (
    <video {...p} style={{ maxWidth: "100%" }} />
  ),
  injectHook("ref", useMediaStreamToVideoRefAndPlay),
  injectHook("stream", useWebcamToMediaStream)
);

export default StreamPreviewContainer;
