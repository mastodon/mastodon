import { useCallback, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Button } from '@/mastodon/components/button';
import { TextInputField } from '@/mastodon/components/form_fields';
import {
  removeField,
  selectFieldById,
} from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';
import { CharCounter } from '../components/char_counter';

const messages = defineMessages({
  editTitle: {
    id: 'account_edit.field_edit_modal.edit_title',
    defaultMessage: 'Edit custom field',
  },
  addTitle: {
    id: 'account_edit.field_edit_modal.add_title',
    defaultMessage: 'Add custom field',
  },
  editLabelField: {
    id: 'account_edit.field_edit_modal.name_label',
    defaultMessage: 'Label',
  },
  editLabelHint: {
    id: 'account_edit.field_edit_modal.name_hint',
    defaultMessage: 'E.g. “Personal website”',
  },
  editValueField: {
    id: 'account_edit.field_edit_modal.value_label',
    defaultMessage: 'Value',
  },
  editValueHint: {
    id: 'account_edit.field_edit_modal.value_hint',
    defaultMessage: 'E.g. “example.me”',
  },
});

export const EditFieldModal: FC<DialogModalProps & { fieldKey?: string }> = ({
  onClose,
  fieldKey,
}) => {
  const intl = useIntl();
  const field = useAppSelector((state) =>
    fieldKey ? selectFieldById(state, fieldKey) : null,
  );
  const [newLabel, setNewLabel] = useState(field?.name ?? '');
  const [newValue, setNewValue] = useState(field?.value ?? '');
  const handleChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      const { name, value } = event.currentTarget;
      if (name === 'label') {
        setNewLabel(value);
      } else if (name === 'value') {
        setNewValue(value);
      }
    },
    [],
  );

  return (
    <DialogModal
      onClose={onClose}
      title={
        field
          ? intl.formatMessage(messages.editTitle)
          : intl.formatMessage(messages.addTitle)
      }
    >
      <TextInputField
        value={newLabel}
        name='label'
        onChange={handleChange}
        label={intl.formatMessage(messages.editLabelField)}
        hint={intl.formatMessage(messages.editLabelHint)}
      />
      <CharCounter
        currentLength={newLabel.length}
        maxLength={255}
        recommended
      />

      <TextInputField
        value={newValue}
        name='value'
        onChange={handleChange}
        label={intl.formatMessage(messages.editValueField)}
        hint={intl.formatMessage(messages.editValueHint)}
      />
      <CharCounter
        currentLength={newLabel.length}
        maxLength={255}
        recommended
      />
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
