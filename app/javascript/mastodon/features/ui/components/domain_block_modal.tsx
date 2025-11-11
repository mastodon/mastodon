import { useCallback, useEffect, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import CampaignIcon from '@/material-icons/400-24px/campaign.svg?react';
import DomainDisabledIcon from '@/material-icons/400-24px/domain_disabled.svg?react';
import HistoryIcon from '@/material-icons/400-24px/history.svg?react';
import PersonRemoveIcon from '@/material-icons/400-24px/person_remove.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import VisibilityOffIcon from '@/material-icons/400-24px/visibility_off.svg?react';
import { blockAccount } from 'mastodon/actions/accounts';
import { blockDomain } from 'mastodon/actions/domain_blocks';
import { closeModal } from 'mastodon/actions/modal';
import { apiRequest } from 'mastodon/api';
import { Button } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ShortNumber } from 'mastodon/components/short_number';
import { useAppDispatch } from 'mastodon/store';

interface DomainBlockPreviewResponse {
  following_count: number;
  followers_count: number;
}

export const DomainBlockModal: React.FC<{
  domain: string;
  accountId: string;
  acct: string;
}> = ({ domain, accountId, acct }) => {
  const dispatch = useAppDispatch();
  const [loading, setLoading] = useState(true);
  const [preview, setPreview] = useState<
    DomainBlockPreviewResponse | 'error' | null
  >(null);

  const handleClick = useCallback(() => {
    if (loading) {
      return; // Prevent destructive action before the preview finishes loading or times out
    }

    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    dispatch(blockDomain(domain));
  }, [dispatch, loading, domain]);

  const handleSecondaryClick = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
    dispatch(blockAccount(accountId));
  }, [dispatch, accountId]);

  const handleCancel = useCallback(() => {
    dispatch(closeModal({ modalType: undefined, ignoreFocus: false }));
  }, [dispatch]);

  useEffect(() => {
    apiRequest<DomainBlockPreviewResponse>('GET', 'v1/domain_blocks/preview', {
      params: { domain },
      timeout: 5000,
    })
      .then((data) => {
        setPreview(data);
        setLoading(false);
        return '';
      })
      .catch(() => {
        setPreview('error');
        setLoading(false);
      });
  }, [domain]);

  return (
    <div className='modal-root__modal safety-action-modal' aria-live='polite'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__header'>
          <div className='safety-action-modal__header__icon'>
            <Icon id='' icon={DomainDisabledIcon} />
          </div>

          <div>
            <h1>
              <FormattedMessage
                id='domain_block_modal.title'
                defaultMessage='Block domain?'
              />
            </h1>
            <div>{domain}</div>
          </div>
        </div>

        <div className='safety-action-modal__bullet-points'>
          {preview &&
            preview !== 'error' &&
            preview.followers_count + preview.following_count > 0 && (
              <div>
                <div className='safety-action-modal__bullet-points__icon'>
                  <Icon id='' icon={PersonRemoveIcon} />
                </div>
                <div>
                  <strong>
                    <FormattedMessage
                      id='domain_block_modal.you_will_lose_num_followers'
                      defaultMessage='You will lose {followersCount, plural, one {{followersCountDisplay} follower} other {{followersCountDisplay} followers}} and {followingCount, plural, one {{followingCountDisplay} person you follow} other {{followingCountDisplay} people you follow}}.'
                      values={{
                        followersCount: preview.followers_count,
                        followersCountDisplay: (
                          <ShortNumber value={preview.followers_count} />
                        ),
                        followingCount: preview.following_count,
                        followingCountDisplay: (
                          <ShortNumber value={preview.following_count} />
                        ),
                      }}
                    />
                  </strong>
                </div>
              </div>
            )}

          {preview === 'error' && (
            <div>
              <div className='safety-action-modal__bullet-points__icon'>
                <Icon id='' icon={PersonRemoveIcon} />
              </div>
              <div>
                <strong>
                  <FormattedMessage
                    id='domain_block_modal.you_will_lose_relationships'
                    defaultMessage='You will lose all followers and people you follow from this server.'
                  />
                </strong>
              </div>
            </div>
          )}

          <div className='safety-action-modal__bullet-points--deemphasized'>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon id='' icon={CampaignIcon} />
            </div>
            <div>
              <FormattedMessage
                id='domain_block_modal.they_wont_know'
                defaultMessage="They won't know they've been blocked."
              />
            </div>
          </div>

          <div className='safety-action-modal__bullet-points--deemphasized'>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon id='' icon={VisibilityOffIcon} />
            </div>
            <div>
              <FormattedMessage
                id='domain_block_modal.you_wont_see_posts'
                defaultMessage="You won't see posts or notifications from users on this server."
              />
            </div>
          </div>

          <div className='safety-action-modal__bullet-points--deemphasized'>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon id='' icon={ReplyIcon} />
            </div>
            <div>
              <FormattedMessage
                id='domain_block_modal.they_cant_follow'
                defaultMessage='Nobody from this server can follow you.'
              />
            </div>
          </div>

          <div className='safety-action-modal__bullet-points--deemphasized'>
            <div className='safety-action-modal__bullet-points__icon'>
              <Icon id='' icon={HistoryIcon} />
            </div>
            <div>
              <FormattedMessage
                id='domain_block_modal.they_can_interact_with_old_posts'
                defaultMessage='People from this server can interact with your old posts.'
              />
            </div>
          </div>
        </div>
      </div>

      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <Button onClick={handleSecondaryClick} secondary>
            <FormattedMessage
              id='domain_block_modal.block_account_instead'
              defaultMessage='Block @{name} instead'
              values={{ name: acct.split('@')[0] }}
            />
          </Button>

          <div className='spacer' />

          <button onClick={handleCancel} className='link-button' type='button'>
            <FormattedMessage
              id='confirmation_modal.cancel'
              defaultMessage='Cancel'
            />
          </button>

          <Button onClick={handleClick} dangerous aria-busy={loading}>
            {loading ? (
              <LoadingIndicator />
            ) : (
              <FormattedMessage
                id='domain_block_modal.block'
                defaultMessage='Block server'
              />
            )}
          </Button>
        </div>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default DomainBlockModal;
