import { useCallback, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import { Button } from '@/mastodon/components/button';
import { EmojiTextInputField } from '@/mastodon/components/form_fields';
import {
  removeField,
  selectFieldById,
  updateField,
} from '@/mastodon/reducers/slices/profile_edit';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { ConfirmationModal } from '../../ui/components/confirmation_modals';
import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { DialogModal } from '../../ui/components/dialog_modal';

import classes from './styles.module.scss';

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
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

const selectFieldLimits = createAppSelector(
  [
    (state) =>
      state.server.getIn(['server', 'configuration', 'accounts']) as
        | ImmutableMap<string, number>
        | undefined,
  ],
  (accounts) => ({
    nameLimit: accounts?.get('profile_field_name_limit'),
    valueLimit: accounts?.get('profile_field_value_limit'),
  }),
);

export const EditFieldModal: FC<DialogModalProps & { fieldKey?: string }> = ({
  onClose,
  fieldKey,
}) => {
  const intl = useIntl();
  const field = useAppSelector((state) => selectFieldById(state, fieldKey));
  const [newLabel, setNewLabel] = useState(field?.name ?? '');
  const [newValue, setNewValue] = useState(field?.value ?? '');

  const { nameLimit, valueLimit } = useAppSelector(selectFieldLimits);
  const isPending = useAppSelector((state) => state.profileEdit.isPending);

  const disabled =
    !nameLimit ||
    !valueLimit ||
    newLabel.length > nameLimit ||
    newValue.length > valueLimit;

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (disabled || isPending) {
      return;
    }
    void dispatch(
      updateField({ id: fieldKey, name: newLabel, value: newValue }),
    ).then(onClose);
  }, [disabled, dispatch, fieldKey, isPending, newLabel, newValue, onClose]);

  return (
    <ConfirmationModal
      onClose={onClose}
      title={
        field
          ? intl.formatMessage(messages.editTitle)
          : intl.formatMessage(messages.addTitle)
      }
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      updating={isPending}
      disabled={disabled}
      className={classes.wrapper}
    >
      <EmojiTextInputField
        value={newLabel}
        onChange={setNewLabel}
        label={intl.formatMessage(messages.editLabelField)}
        hint={intl.formatMessage(messages.editLabelHint)}
        maxLength={nameLimit}
      />

      <EmojiTextInputField
        value={newValue}
        onChange={setNewValue}
        label={intl.formatMessage(messages.editValueField)}
        hint={intl.formatMessage(messages.editValueHint)}
        maxLength={valueLimit}
      />
    </ConfirmationModal>
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
  return (
    <DialogModal onClose={onClose} title='Not implemented yet'>
      <p>Not implemented yet</p>
    </DialogModal>
  );
};
