import { useCallback, useMemo, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { Map as ImmutableMap } from 'immutable';

import { Button } from '@/flavours/glitch/components/button';
import { Callout } from '@/flavours/glitch/components/callout';
import { EmojiTextInputField } from '@/flavours/glitch/components/form_fields';
import {
  removeField,
  selectFieldById,
  updateField,
} from '@/flavours/glitch/reducers/slices/profile_edit';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/flavours/glitch/store';
import { isUrlWithoutProtocol } from '@/flavours/glitch/utils/checks';

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
  limitHeader: {
    id: 'account_edit.field_edit_modal.limit_header',
    defaultMessage: 'Recommended character limit exceeded',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
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

  const customEmojiCodes = useAppSelector(selectEmojiCodes);
  const hasLinkAndEmoji = useMemo(() => {
    const text = `${newLabel} ${newValue}`; // Combine text, as we're searching it all.
    const hasLink = /https?:\/\//.test(text);
    const hasEmoji = customEmojiCodes.some((code) =>
      text.includes(`:${code}:`),
    );
    return hasLink && hasEmoji;
  }, [customEmojiCodes, newLabel, newValue]);
  const hasLinkWithoutProtocol = useMemo(
    () => isUrlWithoutProtocol(newValue),
    [newValue],
  );

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
        counterMax={RECOMMENDED_LIMIT}
        recommended
      />

      <EmojiTextInputField
        value={newValue}
        onChange={setNewValue}
        label={intl.formatMessage(messages.editValueField)}
        hint={intl.formatMessage(messages.editValueHint)}
        maxLength={valueLimit}
        counterMax={RECOMMENDED_LIMIT}
        recommended
      />

      {hasLinkAndEmoji && (
        <Callout variant='warning'>
          <FormattedMessage
            id='account_edit.field_edit_modal.link_emoji_warning'
            defaultMessage='We recommend against the use of custom emoji in combination with urls. Custom fields containing both will display as text only instead of as a link, in order to prevent user confusion.'
          />
        </Callout>
      )}

      {(newLabel.length > RECOMMENDED_LIMIT ||
        newValue.length > RECOMMENDED_LIMIT) && (
        <Callout
          variant='warning'
          title={intl.formatMessage(messages.limitHeader)}
        >
          <FormattedMessage
            id='account_edit.field_edit_modal.limit_message'
            defaultMessage='Mobile users might not see your field in full.'
          />
        </Callout>
      )}

      {hasLinkWithoutProtocol && (
        <Callout variant='warning'>
          <FormattedMessage
            id='account_edit.field_edit_modal.url_warning'
            defaultMessage='To add a link, please include {protocol} at the beginning.'
            description='{protocol} is https://'
            values={{
              protocol: <code>https://</code>,
            }}
          />
        </Callout>
      )}
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
