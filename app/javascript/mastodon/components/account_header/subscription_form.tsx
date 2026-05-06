import { useState, useCallback, useId } from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';
import type { IntlShape } from 'react-intl';

import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { AxiosError } from 'axios';

import { apiSubscribeByEmail } from '@/mastodon/api/accounts';
import type {
  ValidationErrorResponse,
  ValidationError,
} from '@/mastodon/api_types/errors';
import { useAppSelector } from '@/mastodon/store';

import { Button } from '../button';
import { DisplayName } from '../display_name';
import type { FieldStatus } from '../form_fields';
import { TextInputField } from '../form_fields/text_input_field';

import classes from './styles.module.scss';

const messages = defineMessages({
  emailInvalid: {
    id: 'email_subscriptions.validation.email.invalid',
    defaultMessage: 'Invalid email address',
  },
  emailBlocked: {
    id: 'email_subscriptions.validation.email.blocked',
    defaultMessage: 'Blocked email provider',
  },
  email: {
    id: 'email_subscriptions.email',
    defaultMessage: 'Email',
  },
});

const isValidationErrorResponse = (
  data: unknown,
): data is ValidationErrorResponse =>
  typeof data === 'object' &&
  data !== null &&
  'error' in data &&
  'details' in data;

const fieldStatusFromErrors = (
  intl: IntlShape,
  errors: ValidationError[],
): FieldStatus | undefined => {
  const error = errors[0];

  if (!error) {
    return undefined;
  }

  let message: string;

  switch (error.error) {
    case 'ERR_BLOCKED':
      message = intl.formatMessage(messages.emailBlocked);
      break;
    case 'ERR_INVALID':
    default:
      message = intl.formatMessage(messages.emailInvalid);
      break;
  }

  return { variant: 'error', message };
};

export const AccountSubscriptionForm: React.FC<{ accountId: string }> = ({
  accountId,
}) => {
  const account = useAppSelector((state) => state.accounts.get(accountId));
  const intl = useIntl();
  const accessibilityId = useId();

  const [email, setEmail] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [errors, setErrors] = useState<Record<string, ValidationError[]>>({});

  const handleChange = useCallback<React.ChangeEventHandler<HTMLInputElement>>(
    (e) => {
      setEmail(e.target.value);
      setErrors({});
    },
    [],
  );

  const handleSubmit = useCallback<React.FormEventHandler>(
    (e) => {
      e.preventDefault();

      if (email.length === 0) {
        return;
      }

      setSubmitting(true);

      apiSubscribeByEmail(accountId, email)
        .then(() => {
          setSubmitting(false);
          setSubmitted(true);
        })
        .catch((err: unknown) => {
          setSubmitting(false);

          if (err instanceof AxiosError && err.response) {
            const data: unknown = err.response.data;

            if (isValidationErrorResponse(data)) {
              if (data.details.email?.some((k) => k.error === 'ERR_TAKEN')) {
                setSubmitted(true);
                return;
              }

              setErrors(data.details);
            }
          }
        });
    },
    [accountId, email],
  );

  if (submitted) {
    return (
      <div
        className={classNames(classes.bannerBase, classes.bannerBaseCentered)}
      >
        <div className={classes.bannerTextAndActions}>
          <FormattedMessage
            id='email_subscriptions.submitted.title'
            defaultMessage='One more step'
            tagName='h2'
          />
          <FormattedMessage
            id='email_subscriptions.submitted.lead'
            defaultMessage='Check your inbox for an email to finish signing up for email updates.'
          />
        </div>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className={classes.bannerBase} noValidate>
      <div className={classes.bannerTextAndActions}>
        <FormattedMessage
          id='email_subscriptions.form.title'
          defaultMessage='Sign up for email updates from {name}'
          tagName='h2'
          values={{
            name: <DisplayName account={account} variant='simple' />,
          }}
        />
      </div>

      <div className={classes.bannerInputButton}>
        <TextInputField
          id={`${accessibilityId}-input`}
          type='email'
          value={email}
          onChange={handleChange}
          label={intl.formatMessage(messages.email)}
          status={
            errors.email ? fieldStatusFromErrors(intl, errors.email) : undefined
          }
        />

        <Button type='submit' loading={submitting}>
          <FormattedMessage
            id='email_subscriptions.form.action'
            defaultMessage='Subscribe'
          />
        </Button>
      </div>

      <div className={classes.bannerDisclaimer}>
        <FormattedMessage
          id='email_subscriptions.form.bottom'
          defaultMessage='Get posts in your inbox without creating a Mastodon account. Unsubscribe at any time. For more information, refer to the <a>Privacy Policy</a>.'
          values={{ a: (str) => <Link to='/privacy-policy'>{str}</Link> }}
        />
      </div>
    </form>
  );
};
