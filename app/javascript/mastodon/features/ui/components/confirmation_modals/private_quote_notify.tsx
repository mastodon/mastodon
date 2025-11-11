import { forwardRef, useCallback, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { submitCompose } from '@/mastodon/actions/compose';
import { changeSetting } from '@/mastodon/actions/settings';
import { CheckBox } from '@/mastodon/components/check_box';
import { useAppDispatch } from '@/mastodon/store';

import { ConfirmationModal } from './confirmation_modal';
import type { BaseConfirmationModalProps } from './confirmation_modal';
import classes from './styles.module.css';

export const PRIVATE_QUOTE_MODAL_ID = 'quote/private_notify';

const messages = defineMessages({
  title: {
    id: 'confirmations.private_quote_notify.title',
    defaultMessage: 'Share with followers and mentioned users?',
  },
  message: {
    id: 'confirmations.private_quote_notify.message',
    defaultMessage:
      'The person you are quoting and other mentions ' +
      "will be notified and will be able to view your post, even if they're not following you.",
  },
  confirm: {
    id: 'confirmations.private_quote_notify.confirm',
    defaultMessage: 'Publish post',
  },
  cancel: {
    id: 'confirmations.private_quote_notify.cancel',
    defaultMessage: 'Back to editing',
  },
});

export const PrivateQuoteNotify = forwardRef<
  HTMLDivElement,
  BaseConfirmationModalProps
>(
  (
    { onClose },
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    _ref,
  ) => {
    const intl = useIntl();

    const [dismiss, setDismissed] = useState(false);
    const handleDismissToggle = useCallback(() => {
      setDismissed((prev) => !prev);
    }, []);

    const dispatch = useAppDispatch();
    const handleConfirm = useCallback(() => {
      dispatch(submitCompose());
      if (dismiss) {
        dispatch(
          changeSetting(['dismissed_banners', PRIVATE_QUOTE_MODAL_ID], true),
        );
      }
    }, [dismiss, dispatch]);

    return (
      <ConfirmationModal
        title={intl.formatMessage(messages.title)}
        message={intl.formatMessage(messages.message)}
        confirm={intl.formatMessage(messages.confirm)}
        cancel={intl.formatMessage(messages.cancel)}
        onConfirm={handleConfirm}
        onClose={onClose}
        extraContent={
          <label className={classes.checkbox_wrapper}>
            <CheckBox
              value='hide'
              checked={dismiss}
              onChange={handleDismissToggle}
            />{' '}
            <FormattedMessage
              id='confirmations.private_quote_notify.do_not_show_again'
              defaultMessage="Don't show me this message again"
            />
          </label>
        }
      />
    );
  },
);
PrivateQuoteNotify.displayName = 'PrivateQuoteNotify';
