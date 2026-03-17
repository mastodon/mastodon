import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from '@/flavours/glitch/components/button';
import { deleteImage } from '@/flavours/glitch/reducers/slices/profile_edit';
import type { ImageLocation } from '@/flavours/glitch/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

export const ImageDeleteModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose, location }) => {
  const isPending = useAppSelector((state) => state.profileEdit.isPending);
  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    void dispatch(deleteImage({ location })).then(onClose);
  }, [dispatch, location, onClose]);

  return (
    <DialogModal
      onClose={onClose}
      title={
        <FormattedMessage
          id='account_edit.image_delete_modal.title'
          defaultMessage='Delete image?'
        />
      }
      buttons={
        <Button dangerous onClick={handleDelete} disabled={isPending}>
          <FormattedMessage
            id='account_edit.image_delete_modal.delete_button'
            defaultMessage='Delete'
          />
        </Button>
      }
    >
      <FormattedMessage
        id='account_edit.image_delete_modal.confirm'
        defaultMessage='Are you sure you want to delete this image? This action can’t be undone.'
        tagName='p'
      />
    </DialogModal>
  );
};
