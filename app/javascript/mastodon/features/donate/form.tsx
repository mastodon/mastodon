import type { FC, SyntheticEvent } from 'react';
import { useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { DonationFrequency } from '@/mastodon/api_types/donate';
import type { ButtonProps } from '@/mastodon/components/button';
import { Button } from '@/mastodon/components/button';
import { Dropdown } from '@/mastodon/components/dropdown';
import type { SelectItem } from '@/mastodon/components/dropdown_selector';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { useAppSelector } from '@/mastodon/store';
import ExternalLinkIcon from '@/material-icons/400-24px/open_in_new.svg?react';

import type { DonateCheckoutArgs } from './donate_modal';

const messages = defineMessages({
  one_time: { id: 'donate.frequency.one_time', defaultMessage: 'Just once' },
  monthly: { id: 'donate.frequency.monthly', defaultMessage: 'Monthly' },
  yearly: { id: 'donate.frequency.yearly', defaultMessage: 'Yearly' },
});

interface DonateFormProps {
  onSubmit: (args: DonateCheckoutArgs) => void;
}

export const DonateForm: FC<Required<DonateFormProps>> = ({ onSubmit }) => {
  const intl = useIntl();

  const donateData = useAppSelector((state) => state.donate.apiResponse);

  const [frequency, setFrequency] = useState<DonationFrequency>('one_time');
  const handleFrequencyToggle = useCallback((value: DonationFrequency) => {
    return () => {
      setFrequency(value);
    };
  }, []);

  const [currency, setCurrency] = useState<string>(
    donateData?.default_currency ?? 'EUR',
  );
  const currencyOptions: SelectItem[] = useMemo(
    () =>
      Object.keys(donateData?.amounts.one_time ?? []).map((code) => ({
        value: code,
        text: code,
      })),
    [donateData?.amounts],
  );

  const [amount, setAmount] = useState(
    () =>
      donateData?.amounts[frequency][donateData.default_currency]?.[0] ?? 1000,
  );
  const handleAmountChange = useCallback((event: SyntheticEvent) => {
    let newAmount = 1;
    if (event.target instanceof HTMLButtonElement) {
      newAmount = Number.parseInt(event.target.value);
    } else if (event.target instanceof HTMLInputElement) {
      newAmount = event.target.valueAsNumber * 100;
    }
    setAmount(newAmount);
  }, []);
  const amountOptions: SelectItem[] = useMemo(() => {
    const formatter = new Intl.NumberFormat('en', {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    });
    return Object.values(donateData?.amounts[frequency][currency] ?? {}).map(
      (value) => ({
        value: value.toString(),
        text: formatter.format(value / 100),
      }),
    );
  }, [currency, donateData?.amounts, frequency]);

  const handleSubmit = useCallback(() => {
    onSubmit({ frequency, amount, currency });
  }, [amount, currency, frequency, onSubmit]);

  if (!donateData) {
    return <LoadingIndicator />;
  }

  return (
    <>
      <div className='row'>
        {(Object.keys(donateData.amounts) as DonationFrequency[]).map(
          (freq) => (
            <ToggleButton
              key={freq}
              active={frequency === freq}
              onClick={handleFrequencyToggle(freq)}
              text={intl.formatMessage(messages[freq])}
            />
          ),
        )}
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
          step='0.01'
          value={(amount / 100).toFixed(2)}
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

      <Button className='submit' onClick={handleSubmit} block>
        <FormattedMessage
          id='donate.continue'
          defaultMessage='Continue to payment'
        />
        <ExternalLinkIcon />
      </Button>

      <p className='footer'>
        <FormattedMessage
          id='donate.redirect_notice'
          defaultMessage='You will be redirected to joinmastodon.org for secure payment'
        />
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
