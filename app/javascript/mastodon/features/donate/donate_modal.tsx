import type { FC } from 'react';
import { forwardRef, useCallback, useEffect, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { DonationFrequency } from '@/mastodon/api_types/donate';
import { IconButton } from '@/mastodon/components/icon_button';
import { useAppSelector } from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { DonateCheckoutHint } from './checkout';
import { DonateForm } from './form';
import { DonateSuccess } from './success';

import './donate_modal.scss';

interface DonateModalProps {
  onClose: () => void;
}

export interface DonateCheckoutArgs {
  frequency: DonationFrequency;
  amount: number;
  currency: string;
}

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

// TODO: Use environment variable
const CHECKOUT_URL = 'http://localhost:3001/donate/checkout';

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- React throws a warning if not set.
const DonateModal: FC<DonateModalProps> = forwardRef(({ onClose }, ref) => {
  const intl = useIntl();

  const donationData = useAppSelector((state) => state.donate.apiResponse);

  const [donateUrl, setDonateUrl] = useState<string | undefined>();
  const handleCheckout = useCallback(
    ({ frequency, amount, currency }: DonateCheckoutArgs) => {
      const params = new URLSearchParams({
        frequency,
        amount: amount.toString(),
        currency,
        source: window.location.origin,
      });
      setState('checkout');

      const url = `${CHECKOUT_URL}?${params.toString()}`;
      setDonateUrl(url);
      try {
        window.open(url);
      } catch (err) {
        console.warn('Error opening checkout window:', err);
      }
    },
    [],
  );

  // Check response from opened page
  const [state, setState] = useState<'start' | 'checkout' | 'success'>('start');
  useEffect(() => {
    const handler = (event: MessageEvent) => {
      if (event.data === 'payment_success' && state === 'checkout') {
        setState('success');
      }
    };
    window.addEventListener('message', handler);
    return () => {
      window.removeEventListener('message', handler);
    };
  }, [state]);

  return (
    <div className='modal-root__modal dialog-modal donate_modal'>
      <div className='dialog-modal__content'>
        <header className='row'>
          <span className='dialog-modal__header__title title'>
            {state === 'start' && donationData?.donation_message}
          </span>
          <IconButton
            className='dialog-modal__header__close'
            title={intl.formatMessage(messages.close)}
            icon='times'
            iconComponent={CloseIcon}
            onClick={onClose}
          />
        </header>
        <div
          className={classNames('dialog-modal__content__form', 'body', {
            initial: state === 'start',
            checkout: state === 'checkout',
            success: state === 'success',
          })}
        >
          {state === 'start' && <DonateForm onSubmit={handleCheckout} />}
          {state === 'checkout' && <DonateCheckoutHint donateUrl={donateUrl} />}
          {state === 'success' && <DonateSuccess onClose={onClose} />}
        </div>
      </div>
    </div>
  );
});
DonateModal.displayName = 'DonateModal';

// eslint-disable-next-line import/no-default-export -- modal_root expects a default export.
export default DonateModal;
