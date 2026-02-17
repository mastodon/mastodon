import type { FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type { BaseConfirmationModalProps } from '@/mastodon/features/ui/components/confirmation_modals';
import { ConfirmationModal } from '@/mastodon/features/ui/components/confirmation_modals';

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
  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.editTitle)}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={onClose}
      onClose={onClose}
      noCloseOnConfirm
      noFocusButton
    />
  );
};
