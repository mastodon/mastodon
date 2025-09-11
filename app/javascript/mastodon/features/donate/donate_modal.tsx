import type { FC, SyntheticEvent } from 'react';
import { forwardRef, useCallback, useMemo, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { ButtonProps } from '@/mastodon/components/button';
import { Button } from '@/mastodon/components/button';
import { Dropdown } from '@/mastodon/components/dropdown';
import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { IconButton } from '@/mastodon/components/icon_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import ExternalLinkIcon from '@/material-icons/400-24px/open_in_new.svg?react';

import './donate_modal.scss';
import type { DonateServerResponse, DonationFrequency } from './api';
import { useDonateApi } from './api';

interface DonateModalProps {
  onClose: () => void;
}

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- React throws a warning if not set.
const DonateModal: FC<DonateModalProps> = forwardRef(({ onClose }, ref) => {
  const intl = useIntl();

  const donationData = useDonateApi();

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
        <form
          className={classNames('dialog-modal__content__form', {
            loading: !donationData,
          })}
        >
          {!donationData ? (
            <LoadingIndicator />
          ) : (
            <DonateForm data={donationData} />
          )}
        </form>
      </div>
    </div>
  );
});
DonateModal.displayName = 'DonateModal';

const DonateForm: FC<{ data: DonateServerResponse }> = ({ data }) => {
  const [frequency, setFrequency] = useState<DonationFrequency>('one_time');
  const handleFrequencyToggle = useCallback((value: DonationFrequency) => {
    return () => {
      setFrequency(value);
    };
  }, []);

  const [currency, setCurrency] = useState<string>(data.default_currency);
  const currencyOptions: SelectItem[] = useMemo(
    () =>
      Object.keys(data.amounts.one_time).map((code) => ({
        value: code,
        text: code,
      })),
    [data.amounts],
  );

  const [amount, setAmount] = useState(
    () => data.amounts[frequency][data.default_currency]?.[0] ?? 'EUR',
  );
  const handleAmountChange = useCallback((event: SyntheticEvent) => {
    if (
      event.target instanceof HTMLButtonElement ||
      event.target instanceof HTMLInputElement
    ) {
      setAmount(Number.parseInt(event.target.value));
    }
  }, []);
  const amountOptions: SelectItem[] = useMemo(() => {
    const formatter = new Intl.NumberFormat('en', {
      style: 'currency',
      currency,
    });
    return Object.values(data.amounts[frequency][currency] ?? {}).map(
      (value) => ({
        value: value.toString(),
        text: formatter.format(value / 100),
      }),
    );
  }, [currency, data.amounts, frequency]);

  return (
    <>
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
          onChange={setCurrency}
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

      <Button className='submit' block type='submit'>
        Continue to payment
        <ExternalLinkIcon />
      </Button>

      <p className='footer'>
        You will be redirected to joinmastodon.org for secure payment
      </p>
    </>
  );
};

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
