import { useRef, useCallback } from 'react';

import { useSelector, useDispatch } from 'react-redux';

import { changeMediaOrder } from 'flavours/glitch/actions/compose';

import { SensitiveButton } from './sensitive_button';
import { Upload } from './upload';
import { UploadProgress } from './upload_progress';

export const UploadForm = () => {
  const dispatch = useDispatch();
  const mediaIds = useSelector(state => state.getIn(['compose', 'media_attachments']).map(item => item.get('id')));
  const active = useSelector(state => state.getIn(['compose', 'is_uploading']));
  const progress = useSelector(state => state.getIn(['compose', 'progress']));
  const isProcessing = useSelector(state => state.getIn(['compose', 'is_processing']));

  const dragItem = useRef();
  const dragOverItem = useRef();

  const handleDragStart = useCallback(id => {
    dragItem.current = id;
  }, [dragItem]);

  const handleDragEnter = useCallback(id => {
    dragOverItem.current = id;
  }, [dragOverItem]);

  const handleDragEnd = useCallback(() => {
    dispatch(changeMediaOrder(dragItem.current, dragOverItem.current));
    dragItem.current = null;
    dragOverItem.current = null;
  }, [dispatch, dragItem, dragOverItem]);

  return (
    <>
      <UploadProgress active={active} progress={progress} isProcessing={isProcessing} />

      {mediaIds.size > 0 && (
        <div className='compose-form__uploads'>
          {mediaIds.map(id => (
            <Upload
              key={id}
              id={id}
              onDragStart={handleDragStart}
              onDragEnter={handleDragEnter}
              onDragEnd={handleDragEnd}
            />
          ))}
        </div>
      )}

      {!mediaIds.isEmpty() && <SensitiveButton />}
    </>
  );
};
