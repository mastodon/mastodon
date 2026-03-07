import { useCallback, useId, useState } from 'react';
import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { EmojiTextAreaField } from '@/flavours/glitch/components/form_fields';
import type { TextAreaProps } from '@/flavours/glitch/components/form_fields/text_area_field';
import type { BaseConfirmationModalProps } from '@/flavours/glitch/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/flavours/glitch/features/ui/components/confirmation_modals';
import { patchProfile } from '@/flavours/glitch/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';

import classes from './styles.module.scss';

const messages = defineMessages({
  addTitle: {
    id: 'account_edit.bio_modal.add_title',
    defaultMessage: 'Add bio',
  },
  editTitle: {
    id: 'account_edit.bio_modal.edit_title',
    defaultMessage: 'Edit bio',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

export const BioModal: FC<BaseConfirmationModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const titleId = useId();

  const { profile: { bio } = {}, isPending } = useAppSelector(
    (state) => state.profileEdit,
  );
  const [newBio, setNewBio] = useState(bio ?? '');
  const maxLength = useAppSelector(
    (state) =>
      state.server.getIn([
        'server',
        'configuration',
        'accounts',
        'max_note_length',
      ]) as number | undefined,
  );

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    if (!isPending) {
      void dispatch(patchProfile({ note: newBio })).then(onClose);
    }
  }, [dispatch, isPending, newBio, onClose]);

  // TypeScript isn't correctly picking up minRows when on the element directly.
  const textAreaProps = {
    autoSize: true,
    minRows: 3,
  } as const satisfies TextAreaProps;

  return (
    <ConfirmationModal
      title={intl.formatMessage(bio ? messages.editTitle : messages.addTitle)}
      titleId={titleId}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      onClose={onClose}
      updating={isPending}
      disabled={!!maxLength && newBio.length > maxLength}
      noFocusButton
    >
      <EmojiTextAreaField
        label=''
        value={newBio}
        onChange={setNewBio}
        aria-labelledby={titleId}
        maxLength={maxLength}
        className={classes.bioField}
        {...textAreaProps}
        // eslint-disable-next-line jsx-a11y/no-autofocus -- This is a modal, it's fine.
        autoFocus
      />
    </ConfirmationModal>
  );
};
