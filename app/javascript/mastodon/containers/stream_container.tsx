import React, { useEffect, useRef, useState } from "react";
import { useSubscribeStream } from "../actions/stream";
import Video from "../features/video";

type GetProps<FC> = FC extends React.FC<infer X> ? X : never;

function conditionalRender<C extends React.FC<any>>(
  component: C,
  visible: (x: GetProps<C>) => boolean
): React.FC<GetProps<C> & { defaultComponent: React.ReactElement }> {
  return function isCondition(p) {
    if (visible(p)) return component;
    else {
      return p.defaultComponent;
    }
  };
}

function injectStream<C extends React.FC<{ stream: MediaStream } & any>>(
  component: C
): React.FC<Omit<GetProps<C>, "stream"> & { id: string }> {
  return function inject({ id, ...rest }) {
    const stream = useSubscribeStream({ id });
    return component({ stream, ...rest });
  };
}

const VideoStreamElement: React.FC<{ stream: MediaStream | undefined }> = ({
  stream,
}) => {
  const videoRef = useRef<HTMLVideoElement>();

  useEffect(
    function showStream() {
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
      }
    },
    [stream]
  );

  return <Video videoRef={videoRef} />;
};

export const StreamContainer = injectStream(VideoStreamElement);
export const StreamPreviewWithDefaultComponent = injectStream(
  conditionalRender(VideoStreamElement, (p) => Boolean(p.stream))
);

export default StreamContainer;
