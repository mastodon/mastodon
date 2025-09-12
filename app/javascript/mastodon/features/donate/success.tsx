import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import donateIllustration from '@/images/donation_successful.png';
import { focusCompose, resetCompose } from '@/mastodon/actions/compose';
import { Button } from '@/mastodon/components/button';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';

import type { DonateServerResponse } from './api';

interface DonateSuccessProps {
  data: DonateServerResponse;
  onClose: () => void;
}

export const DonateSuccess: FC<DonateSuccessProps> = ({ data, onClose }) => {
  const hasComposerContent = useAppSelector(
    (state) => !!state.compose.get('text'),
  );
  const dispatch = useAppDispatch();
  const handleShare = useCallback(() => {
    const shareText = data.donation_success_post;
    dispatch(resetCompose());
    dispatch(focusCompose(shareText));
    onClose();
  }, [data.donation_success_post, dispatch, onClose]);

  return (
    <>
      <img
        src={donateIllustration}
        alt=''
        role='presentation'
        className='illustration'
      />
      <FormattedMessage
        id='donate.success.title'
        defaultMessage='Thanks for your donation!'
        tagName='h2'
      />
      <FormattedMessage
        id='donate.success.subtitle'
        defaultMessage='You should receive an email confirming your donation soon.'
        tagName='p'
      />

      <Button block onClick={handleShare}>
        <ShareIcon />
        <FormattedMessage
          id='donate.success.share'
          defaultMessage='Spread the word'
        />
      </Button>
      <Button secondary block onClick={onClose}>
        <FormattedMessage id='lightbox.close' defaultMessage='Close' />
      </Button>
      {hasComposerContent && (
        <p className='footer'>
          <FormattedMessage
            id='donate.success.footer'
            defaultMessage='Sharing will overwrite your current post draft.'
          />
        </p>
      )}
    </>
  );
};
