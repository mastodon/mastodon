import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import donateIllustration from '@/images/donation_successful.png';
import { composeDonateShare } from '@/mastodon/actions/donate';
import { Button } from '@/mastodon/components/button';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import ShareIcon from '@/material-icons/400-24px/share.svg?react';

interface DonateSuccessProps {
  onClose: () => void;
}

export const DonateSuccess: FC<DonateSuccessProps> = ({ onClose }) => {
  const hasComposerContent = useAppSelector(
    (state) => !!state.compose.get('text'),
  );
  const dispatch = useAppDispatch();
  const handleShare = useCallback(() => {
    dispatch(composeDonateShare());
  }, [dispatch]);

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
      <p className='muted'>
        <FormattedMessage
          id='donate.success.subtitle'
          defaultMessage='You should receive an email confirming your donation soon.'
        />
      </p>

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
