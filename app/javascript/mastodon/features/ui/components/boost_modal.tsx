import { useCallback, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import { Button } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';
import PrivacyDropdown from 'mastodon/features/compose/components/privacy_dropdown';
import { EmbeddedStatus } from 'mastodon/features/notifications_v2/components/embedded_status';
import type { Status, StatusVisibility } from 'mastodon/models/status';
import { useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  cancel_reblog: {
    id: 'status.cancel_reblog_private',
    defaultMessage: 'Unboost',
  },
  reblog: { id: 'status.reblog', defaultMessage: 'Boost' },
});

export const BoostModal: React.FC<{
  status: Status;
  onClose: () => void;
  onReblog: (status: Status, privacy: StatusVisibility) => void;
}> = ({ status, onReblog, onClose }) => {
  const intl = useIntl();

  const defaultPrivacy = useAppSelector(
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );

  const statusId = status.get('id') as string;
  const statusVisibility = status.get('visibility') as StatusVisibility;

  const [privacy, setPrivacy] = useState<StatusVisibility>(
    statusVisibility === 'private' ? 'private' : defaultPrivacy,
  );

  const onPrivacyChange = useCallback((value: StatusVisibility) => {
    setPrivacy(value);
  }, []);

  const handleReblog = useCallback(() => {
    onReblog(status, privacy);
    onClose();
  }, [onClose, onReblog, status, privacy]);

  const handleCancel = useCallback(() => {
    onClose();
  }, [onClose]);

  const findContainer = useCallback(
    () =>
      document.getElementsByClassName(
        'modal-root__container',
      )[0] as HTMLDivElement,
    [],
  );

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <div className='safety-action-modal__header__icon'>
            <Icon icon={RepeatIcon} id='retweet' />
          </div>

          <div>
            <h1>
              {status.get('reblogged') ? (
                <FormattedMessage
                  id='boost_modal.undo_reblog'
                  defaultMessage='Unboost post?'
                />
              ) : (
                <FormattedMessage
                  id='boost_modal.reblog'
                  defaultMessage='Boost post?'
                />
              )}
            </h1>
            <div>
              <FormattedMessage
                id='boost_modal.combo'
                defaultMessage='You can press {combo} to skip this next time'
                values={{
                  combo: (
                    <span className='hotkey-combination'>
                      <kbd>Shift</kbd>+<Icon id='retweet' icon={RepeatIcon} />
                    </span>
                  ),
                }}
              />
            </div>
          </div>
        </div>

        <div className='safety-action-modal__status'>
          <EmbeddedStatus statusId={statusId} />
        </div>
      </div>

      <div className={classNames('safety-action-modal__bottom')}>
        <div className='safety-action-modal__actions'>
          {!status.get('reblogged') && (
            <PrivacyDropdown
              noDirect
              value={privacy}
              container={findContainer}
              onChange={onPrivacyChange}
              disabled={statusVisibility === 'private'}
            />
          )}

          <div className='spacer' />

          <button onClick={handleCancel} className='link-button' type='button'>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </button>

          <Button
            onClick={handleReblog}
            text={intl.formatMessage(
              status.get('reblogged')
                ? messages.cancel_reblog
                : messages.reblog,
            )}
            /* eslint-disable-next-line jsx-a11y/no-autofocus -- We are in the modal */
            autoFocus
          />
        </div>
      </div>
    </div>
  );
};
