import type { FC } from 'react';

import type { ApiAccountFieldJSON } from '@/mastodon/api_types/accounts';
import { useAppSelector } from '@/mastodon/store';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';

export const EditFieldModal: FC<
  DialogModalProps & { field?: ApiAccountFieldJSON }
> = ({ onClose }) => {
  return (
    <DialogModal onClose={onClose} title='foo'>
      <p>bar</p>
    </DialogModal>
  );
};

export const DeleteFieldModal: FC<
  DialogModalProps & { field: ApiAccountFieldJSON }
> = ({ onClose }) => {
  return (
    <DialogModal onClose={onClose} title='foo'>
      <p>bar</p>
    </DialogModal>
  );
};

export const RearrangeFieldsModal: FC<DialogModalProps> = ({ onClose }) => {
  const fields = useAppSelector(
    (state) => state.profileEdit.profile?.fields ?? [],
  );
  return (
    <DialogModal onClose={onClose} title='foo'>
      {fields.map((field, index) => (
        <p key={index}>{field.name}</p>
      ))}
    </DialogModal>
  );
};
