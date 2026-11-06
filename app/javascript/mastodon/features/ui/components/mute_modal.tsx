import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import {
  CheckboxField,
  RadioButtonField,
  Fieldset,
} from '@/mastodon/components/form_fields';
import { StatusReplyIcon } from '@/mastodon/components/status/icons';
import { useAppDispatch } from '@/mastodon/store';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import CampaignIcon from '@/material-icons/400-24px/campaign.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import VolumeOffIcon from '@/material-icons/400-24px/volume_off.svg?react';
import { muteAccount } from 'mastodon/actions/accounts';
import { closeModal } from 'mastodon/actions/modal';
import { Button } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';
import { NavigationFocusTarget } from 'mastodon/components/navigation_focus_target';

const messages = defineMessages({
  duration: { id: 'mute_modal.duration', defaultMessage: 'Duration' },
  minutes: {
    id: 'intervals.full.minutes',
    defaultMessage: '{number, plural, one {# minute} other {# minutes}}',
  },
  hours: {
    id: 'intervals.full.hours',
    defaultMessage: '{number, plural, one {# hour} other {# hours}}',
  },
  days: {
    id: 'intervals.full.days',
    defaultMessage: '{number, plural, one {# day} other {# days}}',
  },
  indefinite: {
    id: 'mute_modal.indefinite',
    defaultMessage: 'Until I unmute them',
  },
  hideFromNotifications: {
    id: 'mute_modal.hide_from_notifications',
    defaultMessage: 'Hide from notifications',
  },
});

export const MuteModal: React.FC<{ accountId: string; acct: string }> = ({
  accountId,
  acct,
}) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const [notifications, setNotifications] = useState(true);
  const [muteDuration, setMuteDuration] = useState('0');
  const [expanded, setExpanded] = useState(false);

  const handleClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    dispatch(muteAccount(accountId, notifications, Number(muteDuration)));
  }, [dispatch, accountId, notifications, muteDuration]);

  const handleCancel = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
  }, [dispatch]);

  const handleToggleNotifications = useCallback(
    ({ target }: React.ChangeEvent<HTMLInputElement>) => {
      setNotifications(target.checked);
    },
    [setNotifications],
  );

  const handleChangeMuteDuration = useCallback(
    ({ target }: React.ChangeEvent<HTMLInputElement>) => {
      setMuteDuration(target.value);
    },
    [setMuteDuration],
  );

  const handleToggleSettings = useCallback(() => {
    setExpanded(!expanded);
  }, [expanded, setExpanded]);

  const firstExpandedOptionRef = useRef<HTMLInputElement>(null);
  useEffect(() => {
    if (expanded) {
      firstExpandedOptionRef.current?.focus();
    }
  }, [expanded]);

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <div className='safety-action-modal__header__icon'>
            <Icon icon={VolumeOffIcon} />
          </div>

          <div>
            <NavigationFocusTarget as='h1'>
              <FormattedMessage
                id='mute_modal.title'
                defaultMessage='Mute user?'
              />
            </NavigationFocusTarget>
            <p>@{acct}</p>
          </div>
        </div>

        <ul className='safety-action-modal__bullet-points'>
          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={CampaignIcon} />
            </div>
            <div>
              <FormattedMessage
                id='mute_modal.they_wont_know'
                defaultMessage="They won't know they've been muted."
              />
            </div>
          </li>

          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={VisibilityOffIcon} />
            </div>
            <div>
              <FormattedMessage
                id='mute_modal.you_wont_see_posts'
                defaultMessage="They can still see your posts, but you won't see theirs."
              />
            </div>
          </li>

          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={AlternateEmailIcon} />
            </div>
            <div>
              <FormattedMessage
                id='mute_modal.you_wont_see_mentions'
                defaultMessage="You won't see posts that mention them."
              />
            </div>
          </li>

          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={StatusReplyIcon} />
            </div>
            <div>
              <FormattedMessage
                id='mute_modal.they_can_mention_and_follow'
                defaultMessage="They can mention and follow you, but you won't see them."
              />
            </div>
          </li>
        </ul>
      </div>

      <div
        className={classNames('safety-action-modal__bottom', {
          active: expanded,
        })}
      >
        <div className='safety-action-modal__bottom__collapsible'>
          <Fieldset
            legend={intl.formatMessage(messages.duration)}
            name='duration'
          >
            <RadioButtonField
              value='0'
              label={intl.formatMessage(messages.indefinite)}
              checked={muteDuration === '0'}
              onChange={handleChangeMuteDuration}
              ref={firstExpandedOptionRef}
            />
            <RadioButtonField
              value='21600'
              label={intl.formatMessage(messages.hours, { number: 6 })}
              checked={muteDuration === '21600'}
              onChange={handleChangeMuteDuration}
            />
            <RadioButtonField
              value='86400'
              label={intl.formatMessage(messages.hours, { number: 24 })}
              checked={muteDuration === '86400'}
              onChange={handleChangeMuteDuration}
            />
            <RadioButtonField
              value='604800'
              label={intl.formatMessage(messages.days, { number: 7 })}
              checked={muteDuration === '604800'}
              onChange={handleChangeMuteDuration}
            />
            <RadioButtonField
              value='2592000'
              label={intl.formatMessage(messages.days, { number: 30 })}
              checked={muteDuration === '2592000'}
              onChange={handleChangeMuteDuration}
            />
          </Fieldset>

          <CheckboxField
            label={intl.formatMessage(messages.hideFromNotifications)}
            checked={notifications}
            onChange={handleToggleNotifications}
          />
        </div>

        <div className='safety-action-modal__actions'>
          <Button onClick={handleToggleSettings}>
            {expanded ? (
              <FormattedMessage
                id='mute_modal.hide_options'
                defaultMessage='Hide options'
              />
            ) : (
              <FormattedMessage
                id='mute_modal.show_options'
                defaultMessage='Show options'
              />
            )}
          </Button>

          <div className='spacer' />

          <Button onClick={handleCancel}>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </Button>

          <Button
            variant='solid'
            color='accent'
            onClick={handleClick}
            autoFocus
          >
            <FormattedMessage
              id='confirmations.mute.confirm'
              defaultMessage='Mute'
            />
          </Button>
        </div>
      </div>
    </div>
  );
};

export default MuteModal;
