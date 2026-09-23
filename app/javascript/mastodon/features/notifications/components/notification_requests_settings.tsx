import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/mastodon/actions/modal';
import { changeSetting } from '@/mastodon/actions/settings';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalShell,
  ModalActions,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { PolicyControls } from './policy_controls';
import SettingToggle from './setting_toggle';

export const NotificationRequestsSettings = () => {
  const dispatch = useAppDispatch();
  const settings = useAppSelector((state) =>
    state.settings.get('notifications'),
  );

  const onChange = useCallback(
    (key: string[], checked: boolean) => {
      dispatch(changeSetting(['notifications', ...key], checked));
    },
    [dispatch],
  );

  return (
    <div className='column-settings'>
      <section>
        <div className='column-settings__row'>
          <SettingToggle
            prefix='notifications'
            settings={settings}
            settingPath={['minimizeFilteredBanner']}
            onChange={onChange}
            label={
              <FormattedMessage
                id='notification_requests.minimize_banner'
                defaultMessage='Minimize filtered notifications banner'
              />
            }
          />
        </div>
      </section>

      <PolicyControls />
    </div>
  );
};

export const NotificationRequestsSettingsModal: React.FC = () => {
  const dispatch = useAppDispatch();

  const handleCloseModal = useCallback(() => {
    void dispatch(
      closeModal({
        modalType: 'NOTIFICATION_REQUESTS_SETTINGS',
        ignoreFocus: false,
      }),
    );
  }, [dispatch]);

  return (
    <ModalShell>
      <ModalTitle onClose={handleCloseModal}>
        <FormattedMessage
          id='notifications.settings'
          defaultMessage='Notification Settings'
        />
      </ModalTitle>
      <NotificationRequestsSettings />
      <ModalActions>
        <Button variant='solid' onClick={handleCloseModal}>
          <FormattedMessage id='alt_text_modal.done' defaultMessage='Done' />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};
