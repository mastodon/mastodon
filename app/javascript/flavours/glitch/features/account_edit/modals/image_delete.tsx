import type { FC } from 'react';

import type { ImageLocation } from '@/flavours/glitch/reducers/slices/profile_edit';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

export const ImageDeleteModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose }) => {
  return <DialogModal title='TODO' onClose={onClose} />;
};
