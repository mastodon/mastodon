import { useEffect, useState } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { setDragUploadEnabled } from '@/mastodon/actions/compose_typed';
import { selectImageInfo } from '@/mastodon/reducers/slices/profile_edit';
import type { ImageLocation } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

export const ImageUploadModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose, location }) => {
  const { src } = useAppSelector((state) => selectImageInfo(state, location));
  const [step] = useState<'select' | 'crop' | 'alt'>('select');

  const dispatch = useAppDispatch();
  useEffect(() => {
    dispatch(setDragUploadEnabled(false));

    return () => {
      dispatch(setDragUploadEnabled(true));
    };
  }, [dispatch]);

  return (
    <DialogModal
      title={
        src ? (
          <FormattedMessage
            id='account_edit.upload_modal.title_replace'
            defaultMessage='Replace profile photo'
          />
        ) : (
          <FormattedMessage
            id='account_edit.upload_modal.title_add'
            defaultMessage='Add profile photo'
          />
        )
      }
      onClose={onClose}
      noCancelButton
    >
      {step}
    </DialogModal>
  );
};
