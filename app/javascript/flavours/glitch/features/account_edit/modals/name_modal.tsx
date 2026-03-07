import { useCallback, useId, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { EmojiTextInputField } from '@/flavours/glitch/components/form_fields';
import type { BaseConfirmationModalProps } from '@/flavours/glitch/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/flavours/glitch/features/ui/components/confirmation_modals';
import { patchProfile } from '@/flavours/glitch/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';

const messages = defineMessages({
  addTitle: {
    id: 'account_edit.name_modal.add_title',
    defaultMessage: 'Add display name',
  },
  editTitle: {
    id: 'account_edit.name_modal.edit_title',
    defaultMessage: 'Edit display name',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

export const NameModal: FC<BaseConfirmationModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const titleId = useId();

  const { profile: { displayName } = {}, isPending } = useAppSelector(
    (state) => state.profileEdit,
  );
  const maxLength = useAppSelector(
    (state) =>
      state.server.getIn([
        'server',
        'configuration',
        'accounts',
        'max_display_name_length',
      ]) as number | undefined,
  );

  const [newName, setNewName] = useState(displayName ?? '');

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (!isPending) {
      void dispatch(patchProfile({ display_name: newName })).then(onClose);
    }
  }, [dispatch, isPending, newName, onClose]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.editTitle)}
      titleId={titleId}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      onClose={onClose}
      updating={isPending}
      disabled={!!maxLength && newName.length > maxLength}
      noCloseOnConfirm
      noFocusButton
    >
      <EmojiTextInputField
        value={newName}
        onChange={setNewName}
        aria-labelledby={titleId}
        counterMax={maxLength}
        label=''
        // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's fine.
        autoFocus
      />
    </ConfirmationModal>
  );
};
