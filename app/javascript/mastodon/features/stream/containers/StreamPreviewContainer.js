import React, { useRef, useEffect } from 'react';
import { useStore, useSelector } from 'react-redux';

import { removeStream } from '../../../actions/compose';

const StreamPreviewContainer = () => {
  const videoRef = useRef();
  const streamVisible = useSelector((state) =>
    state.getIn(['compose', 'stream']),
  );

  const store = useStore();

  useEffect(() => {
    if (streamVisible && videoRef.current) {
      const handleVideoTrackEnd = () => {
        store.dispatch(removeStream());
      };
      let videoTrack;
      navigator.mediaDevices
        .getUserMedia({ video: true })
        .then((stream) => {

          videoTrack = stream.getVideoTracks()[0];
          videoTrack.addEventListener('ended', handleVideoTrackEnd);
          const mStream = new MediaStream();
          mStream.addTrack(videoTrack);
          videoRef.current.srcObject = mStream;
          videoRef.current.play().catch();
        })
        .catch({});
      return () => {
        videoRef.current.srcObject = undefined;
        videoTrack.stop();
        videoTrack.removeEventListener('ended', handleVideoTrackEnd);
      };
    }
    return () => {};
  }, [streamVisible]);

  return (
    <div>
      <video
        ref={videoRef}
        style={{
          maxWidth: streamVisible ? '100%' : 0,
          display: streamVisible ? undefined : 'none',
        }}
      />
    </div>
  );
};

export default StreamPreviewContainer;
