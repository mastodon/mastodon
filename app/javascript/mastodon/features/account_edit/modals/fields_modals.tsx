import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from '@/mastodon/components/button';
import { removeField } from '@/mastodon/reducers/slices/profile_edit';
import type { FieldData } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';

export const EditFieldModal: FC<DialogModalProps & { field?: FieldData }> = ({
  onClose,
}) => {
  return (
    <DialogModal onClose={onClose} title='foo'>
      <p>bar</p>
    </DialogModal>
  );
};

export const DeleteFieldModal: FC<DialogModalProps & { fieldKey: string }> = ({
  onClose,
  fieldKey,
}) => {
  const isPending = useAppSelector((state) => state.profileEdit.isPending);
  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    void dispatch(removeField({ key: fieldKey })).then(onClose);
  }, [dispatch, fieldKey, onClose]);

  return (
    <DialogModal
      onClose={onClose}
      title={
        <FormattedMessage
          id='account_edit.field_delete_modal.title'
          defaultMessage='Delete custom field?'
        />
      }
      buttons={
        <Button dangerous onClick={handleDelete} disabled={isPending}>
          <FormattedMessage
            id='account_edit.field_delete_modal.delete_button'
            defaultMessage='Delete'
          />
        </Button>
      }
    >
      <FormattedMessage
        id='account_edit.field_delete_modal.confirm'
        defaultMessage='Are you sure you want to delete this custom field? This action can’t be undone.'
        tagName='p'
      />
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
