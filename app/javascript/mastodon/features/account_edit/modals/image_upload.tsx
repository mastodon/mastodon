import type { FC } from 'react';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';
import type { ImageLocation } from '../components/image_edit';

export const ImageUploadModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose }) => {
  return <DialogModal title='TODO' onClose={onClose} />;
};
