import type { MouseEventHandler } from 'react';
import { useCallback, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router';

import type Immutable from 'immutable';

import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import AttachmentList from 'flavours/glitch/components/attachment_list';
import { Icon } from 'flavours/glitch/components/icon';
import { VisibilityIcon } from 'flavours/glitch/components/visibility_icon';
import PrivacyDropdown from 'flavours/glitch/features/compose/components/privacy_dropdown';
import type { Account } from 'flavours/glitch/models/account';
import type { Status, StatusVisibility } from 'flavours/glitch/models/status';
import { useAppSelector } from 'flavours/glitch/store';

import { Avatar } from '../../../components/avatar';
import { Button } from '../../../components/button';
import { DisplayName } from '../../../components/display_name';
import { RelativeTimestamp } from '../../../components/relative_timestamp';
import StatusContent from '../../../components/status_content';

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
  missingMediaDescription?: boolean;
}> = ({ status, onReblog, onClose, missingMediaDescription }) => {
  const intl = useIntl();
  const history = useHistory();

  const default_privacy = useAppSelector(
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );

  const account = status.get('account') as Account;
  const statusVisibility = status.get('visibility') as StatusVisibility;

  const [privacy, setPrivacy] = useState<StatusVisibility>(
    statusVisibility === 'private' ? 'private' : default_privacy,
  );

  const onPrivacyChange = useCallback((value: StatusVisibility) => {
    setPrivacy(value);
  }, []);

  const handleReblog = useCallback(() => {
    onReblog(status, privacy);
    onClose();
  }, [onClose, onReblog, status, privacy]);

  const handleAccountClick = useCallback<MouseEventHandler>(
    (e) => {
      if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
        e.preventDefault();
        onClose();
        history.push(`/@${account.acct}`);
      }
    },
    [history, onClose, account],
  );

  const buttonText = status.get('reblogged')
    ? messages.cancel_reblog
    : messages.reblog;

  const findContainer = useCallback(
    () => document.getElementsByClassName('modal-root__container')[0],
    [],
  );

  return (
    <div className='modal-root__modal boost-modal'>
      <div className='boost-modal__container'>
        <div
          className={classNames(
            'status',
            `status-${statusVisibility}`,
            'light',
          )}
        >
          <div className='status__info'>
            <a
              href={status.get('url') as string}
              className='status__relative-time'
              target='_blank'
              rel='noopener noreferrer'
            >
              <span className='status__visibility-icon'>
                <VisibilityIcon visibility={statusVisibility} />
              </span>
              <RelativeTimestamp
                timestamp={status.get('created_at') as string}
              />
            </a>

            <a
              onClick={handleAccountClick}
              href={account.url}
              className='status__display-name'
            >
              <div className='status__avatar'>
                <Avatar account={account} size={48} />
              </div>

              <DisplayName account={account} />
            </a>
          </div>

          {/* @ts-expect-error Expected until StatusContent is typed */}
          <StatusContent status={status} />

          {(status.get('media_attachments') as Immutable.List<unknown>).size >
            0 && (
            <AttachmentList compact media={status.get('media_attachments')} />
          )}
        </div>
      </div>

      <div className='boost-modal__action-bar'>
        <div>
          {missingMediaDescription ? (
            <FormattedMessage
              id='boost_modal.missing_description'
              defaultMessage='This toot contains some media without description'
            />
          ) : (
            <FormattedMessage
              id='boost_modal.combo'
              defaultMessage='You can press {combo} to skip this next time'
              values={{
                combo: (
                  <span>
                    Shift + <Icon id='retweet' icon={RepeatIcon} />
                  </span>
                ),
              }}
            />
          )}
        </div>
        {statusVisibility !== 'private' && !status.get('reblogged') && (
          <PrivacyDropdown
            noDirect
            value={privacy}
            container={findContainer}
            onChange={onPrivacyChange}
          />
        )}
        <Button
          text={intl.formatMessage(buttonText)}
          onClick={handleReblog}
          // eslint-disable-next-line jsx-a11y/no-autofocus
          autoFocus
        />
      </div>
    </div>
  );
};
