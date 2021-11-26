import React, { useEffect, useRef } from 'react';
import streamStore from '../../../reducers/stream';

const VideoPreview = () => {
  const videoRef = useRef();
  const [videoTrack] = streamStore.useGlobalState('videoTrack');

  useEffect(() => {
    videoRef.current.srcObject = videoTrack;
    videoRef.current.play().catch();
  }, [videoTrack]);

  return <video ref={videoRef} />;
};

const StreamPreviewContainer = () => {
  const [activePreview] = streamStore.useGlobalState('activePreview');

  return activePreview ? <VideoPreview /> : null;
};

export default StreamPreviewContainer;
