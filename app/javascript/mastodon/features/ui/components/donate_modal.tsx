import type { FC, SyntheticEvent } from 'react';
import { forwardRef, useCallback, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { ButtonProps } from '@/mastodon/components/button';
import { Button } from '@/mastodon/components/button';
import { Dropdown } from '@/mastodon/components/dropdown';
import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { IconButton } from '@/mastodon/components/icon_button';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import ExternalLinkIcon from '@/material-icons/400-24px/open_in_new.svg?react';

import type { BaseConfirmationModalProps } from './confirmation_modals/confirmation_modal';

import './donate_model.scss';

type DonateModalProps = BaseConfirmationModalProps;

type Frequency = 'one_time' | 'monthly';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const currencyOptions = [
  {
    value: 'usd',
    text: 'USD',
  },
  {
    value: 'eur',
    text: 'EUR',
  },
] as const satisfies SelectItem[];
type Currency = (typeof currencyOptions)[number]['value'];
function isCurrency(value: string): value is Currency {
  return currencyOptions.some((option) => option.value === value);
}

const amountOptions = [
  { value: '2000', text: '€20' },
  { value: '1000', text: '€10' },
  { value: '500', text: '€5' },
  { value: '300', text: '€3' },
] as const satisfies SelectItem[];

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- React throws a warning if not set.
const DonateModal: FC<DonateModalProps> = forwardRef(({ onClose }, ref) => {
  const intl = useIntl();

  const [frequency, setFrequency] = useState<Frequency>('one_time');
  const handleFrequencyToggle = useCallback((value: Frequency) => {
    return () => {
      setFrequency(value);
    };
  }, []);

  const [currency, setCurrency] = useState<Currency>('usd');
  const handleCurrencyChange = useCallback((value: string) => {
    if (isCurrency(value)) {
      setCurrency(value);
    }
  }, []);

  const [amount, setAmount] = useState(() =>
    Number.parseInt(amountOptions[0].value),
  );
  const handleAmountChange = useCallback((event: SyntheticEvent) => {
    if (
      event.target instanceof HTMLButtonElement ||
      event.target instanceof HTMLInputElement
    ) {
      setAmount(Number.parseInt(event.target.value));
    }
  }, []);

  return (
    <div className='modal-root__modal dialog-modal donate_modal'>
      <div className='dialog-modal__content'>
        <header className='row'>
          <span className='dialog-modal__header__title'>
            By supporting Mastodon, you help sustain a global network that
            values people over profit. Will you join us today?
          </span>
          <IconButton
            className='dialog-modal__header__close'
            title={intl.formatMessage(messages.close)}
            icon='times'
            iconComponent={CloseIcon}
            onClick={onClose}
          />
        </header>
        <div className='dialog-modal__content__form'>
          <div className='row'>
            <ToggleButton
              active={frequency === 'one_time'}
              onClick={handleFrequencyToggle('one_time')}
            >
              One Time
            </ToggleButton>
            <ToggleButton
              active={frequency === 'monthly'}
              onClick={handleFrequencyToggle('monthly')}
            >
              Monthly
            </ToggleButton>
          </div>

          <div className='row row--select'>
            <Dropdown
              items={currencyOptions}
              current={currency}
              classPrefix='donate_modal'
              onChange={handleCurrencyChange}
            />
            <input
              type='number'
              min='1'
              step='1'
              value={amount}
              onChange={handleAmountChange}
            />
          </div>

          <div className='row'>
            {amountOptions.map((option) => (
              <ToggleButton
                key={option.value}
                onClick={handleAmountChange}
                active={amount === Number.parseInt(option.value)}
                value={option.value}
                text={option.text}
              />
            ))}
          </div>

          <Button className='submit' block>
            Continue to payment
            <ExternalLinkIcon />
          </Button>

          <p className='footer'>
            You will be redirected to joinmastodon.org for secure payment
          </p>
        </div>
      </div>
    </div>
  );
});
DonateModal.displayName = 'DonateModal';

const ToggleButton: FC<ButtonProps & { active: boolean }> = ({
  active,
  ...props
}) => {
  return (
    <Button
      block
      {...props}
      className={classNames('toggle', props.className, { active })}
    />
  );
};

// eslint-disable-next-line import/no-default-export -- modal_root expects a default export.
export default DonateModal;
