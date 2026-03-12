import { useState } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { selectImageInfo } from '@/mastodon/reducers/slices/profile_edit';
import type { ImageLocation } from '@/mastodon/reducers/slices/profile_edit';
import { useAppSelector } from '@/mastodon/store';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

export const ImageUploadModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose, location }) => {
  const { src } = useAppSelector((state) => selectImageInfo(state, location));
  const [step] = useState<'select' | 'crop' | 'alt'>('select');

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
