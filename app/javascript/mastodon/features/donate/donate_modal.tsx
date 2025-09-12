import type { FC } from 'react';
import { forwardRef, useCallback, useEffect, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { IconButton } from '@/mastodon/components/icon_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import type { DonateCheckoutArgs } from './api';
import { useDonateApi } from './api';
import { DonateForm } from './form';
import { DonateSuccess } from './success';

import './donate_modal.scss';

interface DonateModalProps {
  onClose: () => void;
}

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

// TODO: Use environment variable
const CHECKOUT_URL = 'http://localhost:3001/donate/checkout';

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- React throws a warning if not set.
const DonateModal: FC<DonateModalProps> = forwardRef(({ onClose }, ref) => {
  const intl = useIntl();

  const donationData = useDonateApi() ?? undefined;

  const [donateUrl, setDonateUrl] = useState<null | string>(null);
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
          className={classNames('dialog-modal__content__form', {
            initial: state === 'start',
            checkout: state === 'checkout',
            success: state === 'success',
          })}
        >
          {state === 'start' &&
            (donationData ? (
              <DonateForm data={donationData} onSubmit={handleCheckout} />
            ) : (
              <LoadingIndicator />
            ))}
          {state === 'checkout' && (
            <p>
              Your session is opened in another tab.
              {donateUrl && (
                <>
                  {' '}
                  If you don&apos;t see it,
                  {/* eslint-disable-next-line react/jsx-no-target-blank -- We want access to the opener in order to detect success. */}
                  <a href={donateUrl} target='_blank'>
                    click here
                  </a>
                  .
                </>
              )}
            </p>
          )}
          {state === 'success' && donationData && (
            <DonateSuccess data={donationData} onClose={onClose} />
          )}
        </div>
      </div>
    </div>
  );
});
DonateModal.displayName = 'DonateModal';

// eslint-disable-next-line import/no-default-export -- modal_root expects a default export.
export default DonateModal;
