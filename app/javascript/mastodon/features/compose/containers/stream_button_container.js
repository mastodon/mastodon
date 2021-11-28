import React, { useCallback, useMemo } from 'react';
import { useStore } from 'react-redux';
import StreamButton from '../components/stream_button';
import streamStore from '../../../reducers/stream';
import { selectWebcam, turnOffWebcam } from '../../../actions/stream';

const Wrapper = () => {
  const [webcam] = streamStore.useGlobalState('webcam');

  const store = useStore();
  store.getState();
  const unavailable = useMemo(
    () =>
      store.getState().getIn(['compose', 'is_uploading']) ||
      store.getState().getIn(['compose', 'media_attachments']).size > 0,
  );

  const handleClick = useCallback(
    function handleClick() {
      if (webcam === undefined) {
        selectWebcam();
      } else {
        turnOffWebcam();
      }
    },
    [webcam],
  );

  return <StreamButton onClick={handleClick} active={webcam !== undefined} unavailable={unavailable} />;
};
export default Wrapper;
