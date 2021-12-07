import React, { useEffect, useRef, useState } from "react";
import { useSubscribeStream } from "../actions/stream";
import Video from "../features/video";

type GetProps<FC> = FC extends React.FC<infer X> ? X : never;

function conditionalRender<Props extends object>(
  component: React.FC<Props>,
  visible: (x: Props) => boolean
): React.FC<Props & { defaultComponent: React.ReactElement }> {
  return function isCondition(p) {
    if (visible(p)) return component(p);
    else {
      return p.defaultComponent;
    }
  };
}

function injectStream<Props extends {stream: MediaStream}>(
  component: React.FC<Props>
): React.FC<Omit<Props, 'stream'> & { id: string }> {
  return function inject(p) {
    const {id, ...rest} = p
    const stream = useSubscribeStream({ id });
    return component({stream, ...rest as unknown as Props});
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
