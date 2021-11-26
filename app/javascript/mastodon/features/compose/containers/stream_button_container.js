import React, { useCallback, useMemo } from 'react';
import { useStore } from 'react-redux';
import StreamButton from '../components/stream_button';
import streamStore from '../../../reducers/stream';

const Wrapper = () => {
  const [videoTrack, setVideoTrack] = streamStore.useGlobalState('videoTrack');
  const [activePreview, setActivePreview] =
    streamStore.useGlobalState('activePreview');
  const store = useStore();
  store.getState();
  const unavailable = useMemo(
    () =>
      store.getState().getIn(['compose', 'is_uploading']) ||
      store.getState().getIn(['compose', 'media_attachments']).size > 0,
  );

  const handleClick = useCallback(
    function handleClick() {
      if (activePreview) {
        setVideoTrack((p) => {
          p.getTracks().forEach((x) => x.stop());
          return new MediaStream();
        });
      } else {
        navigator.mediaDevices
          .getUserMedia({ video: true })
          .then((stream) => {
            const videoTrack_ = stream.getVideoTracks()[0];
            videoTrack_.addEventListener('ended', () => {
              setActivePreview(false);
              setVideoTrack((p) => {
                p.removeTrack(videoTrack_);
                return p;
              });
            });
            setVideoTrack(() => {
              const n = new MediaStream();
              n.addTrack(videoTrack_);
              return n;
            });
          })
          .catch({});
      }
      setActivePreview((p) => !p);
    },
    [videoTrack],
  );

  return <StreamButton onClick={handleClick} active={activePreview} unavailable={unavailable} />;
};
export default Wrapper;
