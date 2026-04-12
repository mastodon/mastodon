import { forwardRef, useCallback, useImperativeHandle, useState } from 'react';
import type { FC, FocusEventHandler } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import type { FieldStatus } from '@/mastodon/components/form_fields';
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
import { isUrlWithoutProtocol } from '@/mastodon/utils/checks';

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
    defaultMessage: 'E.g. “https://example.me”',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
  discardMessage: {
    id: 'account_edit.field_edit_modal.discard_message',
    defaultMessage:
      'You have unsaved changes. Are you sure you want to discard them?',
  },
  discardConfirm: {
    id: 'account_edit.field_edit_modal.discard_confirm',
    defaultMessage: 'Discard',
  },
  errorBlank: {
    id: 'form_error.blank',
    defaultMessage: 'Field cannot be blank.',
  },
  warningLength: {
    id: 'account_edit.field_edit_modal.length_warning',
    defaultMessage:
      'Recommended character limit exceeded. Mobile users might not see your field in full.',
  },
  warningUrlEmoji: {
    id: 'account_edit.field_edit_modal.link_emoji_warning',
    defaultMessage:
      'We recommend against the use of custom emoji in combination with urls. Custom fields containing both will display as text only instead of as a link, in order to prevent user confusion.',
  },
  warningUrlProtocol: {
    id: 'account_edit.field_edit_modal.url_warning',
    defaultMessage:
      'To add a link, please include {protocol} at the beginning.',
    description: '{protocol} is https://',
  },
});

// We have two different values- the hard limit set by the server,
// and the soft limit for mobile display.
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

const RECOMMENDED_LIMIT = 40;

const selectEmojiCodes = createAppSelector(
  [(state) => state.custom_emojis],
  (emojis) => emojis.map((emoji) => emoji.get('shortcode')).toArray(),
);

interface ConfirmationMessage {
  message: string;
  confirm: string;
  props: { fieldKey?: string; lastLabel: string; lastValue: string };
}

interface ModalRef {
  getCloseConfirmationMessage: () => null | ConfirmationMessage;
}

export const EditFieldModal = forwardRef<
  ModalRef,
  DialogModalProps & {
    fieldKey?: string;
    lastLabel?: string;
    lastValue?: string;
  }
>(({ onClose, fieldKey, lastLabel, lastValue }, ref) => {
  const intl = useIntl();
  const field = useAppSelector((state) => selectFieldById(state, fieldKey));
  const oldLabel = lastLabel ?? field?.name;
  const oldValue = lastValue ?? field?.value;
  const [newLabel, setNewLabel] = useState(oldLabel ?? '');
  const [newValue, setNewValue] = useState(oldValue ?? '');
  const isDirty = newLabel !== oldLabel || newValue !== oldValue;

  const { nameLimit, valueLimit } = useAppSelector(selectFieldLimits);
  const isPending = useAppSelector((state) => state.profileEdit.isPending);

  const [fieldStatuses, setFieldStatuses] = useState<{
    label?: FieldStatus;
    value?: FieldStatus;
  }>({});

  const customEmojiCodes = useAppSelector(selectEmojiCodes);
  const checkField = useCallback(
    (value: string): FieldStatus | null => {
      if (!value.trim()) {
        return {
          variant: 'error',
          message: intl.formatMessage(messages.errorBlank),
        };
      }

      if (value.length > RECOMMENDED_LIMIT) {
        return {
          variant: 'warning',
          message: intl.formatMessage(messages.warningLength, {
            max: RECOMMENDED_LIMIT,
          }),
        };
      }

      const hasLink = /https?:\/\//.test(value);
      const hasEmoji = customEmojiCodes.some((code) =>
        value.includes(`:${code}:`),
      );
      if (hasLink && hasEmoji) {
        return {
          variant: 'warning',
          message: intl.formatMessage(messages.warningUrlEmoji),
        };
      }

      if (isUrlWithoutProtocol(value)) {
        return {
          variant: 'warning',
          message: intl.formatMessage(messages.warningUrlProtocol, {
            protocol: 'https://',
          }),
        };
      }

      return null;
    },
    [customEmojiCodes, intl],
  );

  const handleBlur: FocusEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const { name, value } = event.target;
      const result = checkField(value);
      if (name !== 'label' && name !== 'value') {
        return;
      }
      setFieldStatuses((statuses) => ({
        ...statuses,
        [name]: result ?? undefined,
      }));
    },
    [checkField],
  );

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (isPending) {
      return;
    }

    const labelStatus = checkField(newLabel);
    const valueStatus = checkField(newValue);
    if (labelStatus?.variant === 'error' || valueStatus?.variant === 'error') {
      setFieldStatuses({
        label: labelStatus ?? undefined,
        value: valueStatus ?? undefined,
      });
      return;
    }

    void dispatch(
      updateField({ id: fieldKey, name: newLabel, value: newValue }),
    ).then(() => {
      // Close without confirmation.
      dispatch(
        closeModal({
          modalType: 'ACCOUNT_EDIT_FIELD_EDIT',
          ignoreFocus: false,
        }),
      );
    });
  }, [checkField, dispatch, fieldKey, isPending, newLabel, newValue]);

  useImperativeHandle(
    ref,
    () => ({
      getCloseConfirmationMessage: () => {
        if (!newLabel || !newValue || !isDirty) {
          return null;
        }
        return {
          message: intl.formatMessage(messages.discardMessage),
          confirm: intl.formatMessage(messages.discardConfirm),
          props: {
            fieldKey,
            lastLabel: newLabel,
            lastValue: newValue,
          },
        };
      },
    }),
    [fieldKey, intl, isDirty, newLabel, newValue],
  );

  return (
    <ConfirmationModal
      noCloseOnConfirm
      onClose={onClose}
      title={
        field
          ? intl.formatMessage(messages.editTitle)
          : intl.formatMessage(messages.addTitle)
      }
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      updating={isPending}
      className={classes.wrapper}
    >
      <EmojiTextInputField
        name='label'
        value={newLabel}
        onChange={setNewLabel}
        onBlur={handleBlur}
        label={intl.formatMessage(messages.editLabelField)}
        hint={intl.formatMessage(messages.editLabelHint)}
        status={fieldStatuses.label}
        maxLength={nameLimit}
        counterMax={RECOMMENDED_LIMIT}
        recommended
      />

      <EmojiTextInputField
        name='value'
        value={newValue}
        onChange={setNewValue}
        onBlur={handleBlur}
        label={intl.formatMessage(messages.editValueField)}
        hint={intl.formatMessage(messages.editValueHint)}
        status={fieldStatuses.value}
        maxLength={valueLimit}
        counterMax={RECOMMENDED_LIMIT}
        recommended
      />
    </ConfirmationModal>
  );
});
EditFieldModal.displayName = 'EditFieldModal';

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
