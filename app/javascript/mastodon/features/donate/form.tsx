import type { FC, FocusEventHandler, SyntheticEvent } from 'react';
import { useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import type {
  DonateServerResponse,
  DonationFrequency,
} from '@/mastodon/api_types/donate';
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

const DefaultAmount = 1000; // 10.00

export const DonateForm: FC<DonateFormProps> = (props) => {
  const donateData = useAppSelector((state) => state.donate.apiResponse);
  if (!donateData) {
    return <LoadingIndicator />;
  }
  return <DonateFormInner {...props} data={donateData} />;
};

export const DonateFormInner: FC<
  DonateFormProps & { data: DonateServerResponse }
> = ({ onSubmit, data: donateData }) => {
  const intl = useIntl();

  const [frequency, setFrequency] = useState<DonationFrequency>('one_time');
  // Nested function to allow passing parameters in onClick.
  const handleFrequencyToggle = useCallback((value: DonationFrequency) => {
    return () => {
      setFrequency(value);
    };
  }, []);

  const [currency, setCurrency] = useState(donateData.default_currency);
  const currencyOptions: SelectItem[] = useMemo(
    () =>
      Object.keys(donateData.amounts.one_time).map((code) => ({
        value: code,
        text: code,
      })),
    [donateData.amounts],
  );

  // Amounts handling
  const [amount, setAmount] = useState(
    () =>
      donateData.amounts[frequency][donateData.default_currency]?.[0] ??
      DefaultAmount,
  );
  const handleAmountChange = useCallback((event: SyntheticEvent) => {
    // Coerce the value into a valid amount depending on the source of the event.
    let newAmount = 1;
    if (event.target instanceof HTMLButtonElement) {
      newAmount = Number.parseInt(event.target.value);
    } else if (event.target instanceof HTMLInputElement) {
      newAmount = event.target.valueAsNumber * 100;
    }
    // If invalid, just use the default.
    if (Number.isNaN(newAmount) || newAmount < 1) {
      newAmount = DefaultAmount;
    }
    setAmount(newAmount);
  }, []);
  // The input field is uncontrolled to not interfere with user input, but set the value to the state on blue.
  const handleAmountBlur: FocusEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      event.target.value = (amount / 100).toFixed(2);
    },
    [amount],
  );
  const amountOptions: SelectItem[] = useMemo(() => {
    const formatter = new Intl.NumberFormat('en', {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    });
    return Object.values(donateData.amounts[frequency][currency] ?? {}).map(
      (value) => ({
        value: value.toString(),
        text: formatter.format(value / 100),
      }),
    );
  }, [currency, donateData.amounts, frequency]);

  const handleSubmit = useCallback(() => {
    onSubmit({ frequency, amount, currency });
  }, [amount, currency, frequency, onSubmit]);

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
          onChange={handleAmountChange}
          onBlur={handleAmountBlur}
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
