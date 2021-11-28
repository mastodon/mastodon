import React, { useEffect, useRef } from 'react';
import streamStore from '../../../reducers/stream';

const VideoPreview = () => {
  const videoRef = useRef<any>();
  const [webcam] = streamStore.useGlobalState('webcam');

  useEffect(() => {
    const m = new MediaStream();
    m.addTrack(webcam);
    if(videoRef.current){
      videoRef.current.srcObject = m;
      videoRef.current.play().catch();
      return () => {
        videoRef.current.srcObject = undefined;
      }
    }
  }, [webcam]);

  return <video ref={videoRef} />;
};

const StreamPreviewContainer = () => {
  const [activePreview] = streamStore.useGlobalState('webcam');

  return activePreview ? <VideoPreview /> : null;
};

export default StreamPreviewContainer;
