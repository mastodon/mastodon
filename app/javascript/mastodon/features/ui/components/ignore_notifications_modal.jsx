import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useDispatch } from 'react-redux';

import InventoryIcon from '@/material-icons/400-24px/inventory_2.svg?react';
import PersonAlertIcon from '@/material-icons/400-24px/person_alert.svg?react';
import ShieldQuestionIcon from '@/material-icons/400-24px/shield_question.svg?react';
import { closeModal } from 'mastodon/actions/modal';
import { updateNotificationsPolicy } from 'mastodon/actions/notification_policies';
import { Button } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';

export const IgnoreNotificationsModal = ({ filterType }) => {
  const dispatch = useDispatch();

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

  switch(filterType) {
  case 'for_not_following':
    title = <FormattedMessage id='ignore_notifications_modal.not_following_title' defaultMessage="Ignore notifications from people you don't follow?" />;
    break;
  case 'for_not_followers':
    title = <FormattedMessage id='ignore_notifications_modal.not_followers_title' defaultMessage='Ignore notifications from people not following you?' />;
    break;
  case 'for_new_accounts':
    title = <FormattedMessage id='ignore_notifications_modal.new_accounts_title' defaultMessage='Ignore notifications from new accounts?' />;
    break;
  case 'for_private_mentions':
    title = <FormattedMessage id='ignore_notifications_modal.private_mentions_title' defaultMessage='Ignore notifications from unsolicited Private Mentions?' />;
    break;
  case 'for_limited_accounts':
    title = <FormattedMessage id='ignore_notifications_modal.limited_accounts_title' defaultMessage='Ignore notifications from moderated accounts?' />;
    break;
  }

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <h1>{title}</h1>
        </div>

        <div className='safety-action-modal__bullet-points'>
          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={InventoryIcon} /></div>
            <div><FormattedMessage id='ignore_notifications_modal.filter_to_review_separately' defaultMessage='You can review filtered notifications separately' /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={PersonAlertIcon} /></div>
            <div><FormattedMessage id='ignore_notifications_modal.filter_to_act_users' defaultMessage="You'll still be able to accept, reject, or report users" /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={ShieldQuestionIcon} /></div>
            <div><FormattedMessage id='ignore_notifications_modal.filter_to_avoid_confusion' defaultMessage='Filtering helps avoid potential confusion' /></div>
          </div>
        </div>

        <div>
          <FormattedMessage id='ignore_notifications_modal.disclaimer' defaultMessage="Mastodon cannot inform users that you've ignored their notifications. Ignoring notifications will not stop the messages themselves from being sent." />
        </div>
      </div>


      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <Button onClick={handleSecondaryClick} secondary>
            <FormattedMessage id='ignore_notifications_modal.filter_instead' defaultMessage='Filter instead' />
          </Button>

          <div className='spacer' />

          <button onClick={handleCancel} className='link-button'>
            <FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' />
          </button>

          <button onClick={handleClick} className='link-button'>
            <FormattedMessage id='ignore_notifications_modal.ignore' defaultMessage='Ignore notifications' />
          </button>
        </div>
      </div>
    </div>
  );
};

IgnoreNotificationsModal.propTypes = {
  filterType: PropTypes.string.isRequired,
};

export default IgnoreNotificationsModal;
