import type { FC } from 'react';

import type { ImageLocation } from '@/mastodon/reducers/slices/profile_edit';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

export const ImageAltModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose }) => {
  return <DialogModal title='TODO' onClose={onClose} />;
};
