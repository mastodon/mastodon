import PropTypes from 'prop-types';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useDispatch } from 'react-redux';

import CampaignIcon from '@/material-icons/400-24px/campaign.svg?react';
import DomainDisabledIcon from '@/material-icons/400-24px/domain_disabled.svg?react';
import HistoryIcon from '@/material-icons/400-24px/history.svg?react';
import PersonRemoveIcon from '@/material-icons/400-24px/person_remove.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import { blockAccount } from 'flavours/glitch/actions/accounts';
import { blockDomain } from 'flavours/glitch/actions/domain_blocks';
import { closeModal } from 'flavours/glitch/actions/modal';
import { Button } from 'flavours/glitch/components/button';
import { Icon } from 'flavours/glitch/components/icon';

export const DomainBlockModal = ({ domain, accountId, acct }) => {
  const dispatch = useDispatch();

  const handleClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    dispatch(blockDomain(domain));
  }, [dispatch, domain]);

  const handleSecondaryClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    dispatch(blockAccount(accountId));
  }, [dispatch, accountId]);

  const handleCancel = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
  }, [dispatch]);

  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <div className='safety-action-modal__header__icon'>
            <Icon icon={DomainDisabledIcon} />
          </div>

          <div>
            <h1><FormattedMessage id='domain_block_modal.title' defaultMessage='Block domain?' /></h1>
            <div>{domain}</div>
          </div>
        </div>

        <div className='safety-action-modal__bullet-points'>
          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={CampaignIcon} /></div>
            <div><FormattedMessage id='domain_block_modal.they_wont_know' defaultMessage="They won't know they've been blocked." /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={VisibilityOffIcon} /></div>
            <div><FormattedMessage id='domain_block_modal.you_wont_see_posts' defaultMessage="You won't see posts or notifications from users on this server." /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={PersonRemoveIcon} /></div>
            <div><FormattedMessage id='domain_block_modal.you_will_lose_followers' defaultMessage='All your followers from this server will be removed.' /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={ReplyIcon} /></div>
            <div><FormattedMessage id='domain_block_modal.they_cant_follow' defaultMessage='Nobody from this server can follow you.' /></div>
          </div>

          <div>
            <div className='safety-action-modal__bullet-points__icon'><Icon icon={HistoryIcon} /></div>
            <div><FormattedMessage id='domain_block_modal.they_can_interact_with_old_posts' defaultMessage='People from this server can interact with your old posts.' /></div>
          </div>
        </div>
      </div>

      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <Button onClick={handleSecondaryClick} secondary>
            <FormattedMessage id='domain_block_modal.block_account_instead' defaultMessage='Block @{name} instead' values={{ name: acct.split('@')[0] }} />
          </Button>

          <div className='spacer' />

          <button onClick={handleCancel} className='link-button'>
            <FormattedMessage id='confirmation_modal.cancel' defaultMessage='Cancel' />
          </button>

          <Button onClick={handleClick}>
            <FormattedMessage id='domain_block_modal.block' defaultMessage='Block server' />
          </Button>
        </div>
      </div>
    </div>
  );
};

DomainBlockModal.propTypes = {
  domain: PropTypes.string.isRequired,
  accountId: PropTypes.string.isRequired,
  acct: PropTypes.string.isRequired,
};

export default DomainBlockModal;
