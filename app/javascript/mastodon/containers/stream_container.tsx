import React, { useEffect, useRef, useState } from "react";
import { useSubscribeStream } from "../actions/stream";
import Video from "../features/video";
import { pipe, flip, FunctionN, flow } from "fp-ts/function";
import { right } from "fp-ts/Either";
import * as _ from "fp-ts/IO";
import * as O from "fp-ts/Either";

function conditionalRender<Props extends {}>(
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

type HookGetter<P extends {}, Result> = (p: P) => Result;
type GetHookProps<H> = H extends HookGetter<infer P, any> ? P : never;
type GetHookResult<H> = H extends HookGetter<any, infer R> ? R : never;

function injectHook<
  Props extends Partial<{ [k in Name]: GetHookResult<Hook> }>,
  Hook extends HookGetter<any, any>,
  Name extends keyof Props
>(
  component: React.FC<Props>,
  name: Name,
  getHook: Hook
): React.FC<Omit<Props, Name> & GetHookProps<Hook>> {
  return function getComponentWithInjectedHook(p: Props) {
    const hook = getHook(p);
    return component({ [name]: hook, ...p } as any);
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

const Com = () => <div>asd</div>;

export const StreamContainer = injectHook(
  VideoStreamElement,
  "stream",
  useSubscribeStream
);

const VideoViewWithDefault = conditionalRender(
  VideoStreamElement,
  (p) => !!p.stream
);

export const StreamPreviewWithDefaultComponent = injectHook(
  VideoViewWithDefault,
  "stream",
  useSubscribeStream
);

export default StreamContainer;
