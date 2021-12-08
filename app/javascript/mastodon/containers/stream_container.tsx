import { pipe } from "fp-ts/function";
import React from "react";
import {
  useMediaStreamToVideoRef,
  useSubscribeStream
} from "../actions/stream";
import Video from "../features/video";
import { injectHook, withDefaultComponent } from "../utils/fp";

export const StreamContainer = pipe(
  (p: { videoRef: React.MutableRefObject<HTMLVideoElement> }) => (
    <Video {...p} />
  ),
  injectHook("videoRef", useMediaStreamToVideoRef),
  withDefaultComponent((x) => Boolean(x.stream)),
  injectHook("stream", useSubscribeStream)
);

export default StreamContainer;
