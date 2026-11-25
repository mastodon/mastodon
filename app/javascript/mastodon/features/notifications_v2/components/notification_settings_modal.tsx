import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button';
import {
  ModalActions,
  ModalBody,
  ModalShell,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import { useAppDispatch } from '@/mastodon/store';

import NotificationSettings from '../../notifications/containers/column_settings_container';

const NotificationSettingsModal: React.FC = () => {
  const dispatch = useAppDispatch();

  const handleCloseModal = useCallback(() => {
    void dispatch(
      closeModal({ modalType: 'NOTIFICATION_SETTINGS', ignoreFocus: false }),
    );
  }, [dispatch]);

  return (
    <ModalShell maxWidth={540}>
      <ModalTitle onClose={handleCloseModal}>
        <FormattedMessage
          id='notifications.settings'
          defaultMessage='Notification Settings'
        />
      </ModalTitle>
      <ModalBody>
        <NotificationSettings />
      </ModalBody>
      <ModalActions>
        <Button variant='solid' color='accent' onClick={handleCloseModal}>
          <FormattedMessage id='alt_text_modal.done' defaultMessage='Done' />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default NotificationSettingsModal;
