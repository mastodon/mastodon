import { useCallback } from 'react';
import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import donateBannerImage from '@/images/donation_banner.png';
import { showDonateModal } from '@/mastodon/actions/donate';
import { Button } from '@/mastodon/components/button';
import { DismissableBanner } from '@/mastodon/components/dismissable_banner';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import './styles.scss';

export const DonateBanner: FC = () => {
  const donationData = useAppSelector((state) => state.donate.apiResponse);
  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    dispatch(showDonateModal());
  }, [dispatch]);

  if (!donationData) {
    return null;
  }
  return (
    <DismissableBanner
      id={`donate-${donationData.id}`}
      className='donate_banner'
    >
      <FormattedMessage
        id='donate.banner.title'
        defaultMessage='Support Mastodon'
        tagName='h2'
      />
      <p>{donationData.banner_message}</p>
      <Button text={donationData.banner_button_text} onClick={handleClick} />
      <img src={donateBannerImage} alt='' role='presentation' />
    </DismissableBanner>
  );
};
