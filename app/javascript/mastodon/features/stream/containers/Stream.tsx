import React, { useEffect, useRef, useState, VideoHTMLAttributes } from "react";
import streamStore from "../../../reducers/stream";
import { startStream, subscribeChannel } from "../mediasoupStreamingService";

const StreamPreview = () => {
  const videoRef = useRef<HTMLVideoElement>();

  function startStream_() {
    subscribeChannel((p, t) => {
      startStream(p, t, {
        onStreamChange: (s) => {
          console.log("set stream", s);
          if (videoRef.current) {
            videoRef.current.muted = true;
            videoRef.current.srcObject = s;
            videoRef.current.load();
          }
        },
      });
    });
  }

  useEffect(() => {
    startStream_();
  }, []);

  return (
    <div onClick={() => {}}>
      <video ref={videoRef} muted autoPlay style={{ maxWidth: "100%" }} />
    </div>
  );
};

export default StreamPreview;
