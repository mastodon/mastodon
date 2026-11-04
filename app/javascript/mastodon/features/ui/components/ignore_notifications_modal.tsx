import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useAppDispatch } from '@/mastodon/store';
import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import PersonAlertIcon from '@/material-icons/400-24px/person_alert.svg?react';
import ShieldQuestionIcon from '@/material-icons/400-24px/shield_question.svg?react';
import { closeModal } from 'mastodon/actions/modal';
import { updateNotificationsPolicy } from 'mastodon/actions/notification_policies';
import { Button } from 'mastodon/components/button/redesign';
import { Icon } from 'mastodon/components/icon';
import { NavigationFocusTarget } from 'mastodon/components/navigation_focus_target';

type FilterType =
  | 'for_not_following'
  | 'for_not_followers'
  | 'for_new_accounts'
  | 'for_private_mentions'
  | 'for_limited_accounts'
  | 'for_bots';

export const IgnoreNotificationsModal: React.FC<{ filterType: FilterType }> = ({
  filterType,
}) => {
  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    void dispatch(updateNotificationsPolicy({ [filterType]: 'drop' }));
  }, [dispatch, filterType]);

  const handleSecondaryClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    void dispatch(updateNotificationsPolicy({ [filterType]: 'filter' }));
  }, [dispatch, filterType]);

  const handleCancel = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
  }, [dispatch]);

  let title = null;

  switch (filterType) {
    case 'for_not_following':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.not_following_title'
          defaultMessage="Ignore notifications from people you don't follow?"
        />
      );
      break;
    case 'for_not_followers':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.not_followers_title'
          defaultMessage='Ignore notifications from people not following you?'
        />
      );
      break;
    case 'for_new_accounts':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.new_accounts_title'
          defaultMessage='Ignore notifications from new accounts?'
        />
      );
      break;
    case 'for_private_mentions':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.private_mentions_title'
          defaultMessage='Ignore notifications for unsolicited messages?'
        />
      );
      break;
    case 'for_limited_accounts':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.limited_accounts_title'
          defaultMessage='Ignore notifications from moderated accounts?'
        />
      );
      break;
    case 'for_bots':
      title = (
        <FormattedMessage
          id='ignore_notifications_modal.bots_title'
          defaultMessage='Ignore notifications from bots?'
        />
      );
      break;
  }

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <NavigationFocusTarget as='h1'>{title}</NavigationFocusTarget>
        </div>

        <ul className='safety-action-modal__bullet-points'>
          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={InventoryIcon} />
            </div>
            <div>
              <FormattedMessage
                id='ignore_notifications_modal.filter_to_review_separately'
                defaultMessage='You can review filtered notifications separately'
              />
            </div>
          </li>

          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={PersonAlertIcon} />
            </div>
            <div>
              <FormattedMessage
                id='ignore_notifications_modal.filter_to_act_users'
                defaultMessage="You'll still be able to accept, reject, or report users"
              />
            </div>
          </li>

          <li>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon icon={ShieldQuestionIcon} />
            </div>
            <div>
              <FormattedMessage
                id='ignore_notifications_modal.filter_to_avoid_confusion'
                defaultMessage='Filtering helps avoid potential confusion'
              />
            </div>
          </li>
        </ul>

        <div>
          <FormattedMessage
            id='ignore_notifications_modal.disclaimer'
            defaultMessage="Mastodon cannot inform users that you've ignored their notifications. Ignoring notifications will not stop the messages themselves from being sent."
          />
        </div>
      </div>

      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <Button onClick={handleSecondaryClick} color='accent'>
            <FormattedMessage
              id='ignore_notifications_modal.filter_instead'
              defaultMessage='Filter instead'
            />
          </Button>

          <div className='spacer' />

          <Button onClick={handleCancel}>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </Button>

          <Button onClick={handleClick} variant='solid' color='destructive'>
            <FormattedMessage
              id='ignore_notifications_modal.ignore'
              defaultMessage='Ignore notifications'
            />
          </Button>
        </div>
      </div>
    </div>
  );
};

export default IgnoreNotificationsModal;
