import type { FC } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import IconVerified from '@/images/icons/icon_verified.svg?react';
import { DisplayName } from '@/mastodon/components/display_name';
import { AnimateEmojiProvider } from '@/mastodon/components/emoji/context';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { Icon } from '@/mastodon/components/icon';
import { IconButton } from '@/mastodon/components/icon_button';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { useElementHandledLink } from '@/mastodon/components/status/handled_link';
import { useAccount } from '@/mastodon/hooks/useAccount';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import classes from './redesign.module.scss';

export const AccountFieldsModal: FC<{
  accountId: string;
  onClose: () => void;
}> = ({ accountId, onClose }) => {
  const intl = useIntl();
  const account = useAccount(accountId);
  const htmlHandlers = useElementHandledLink();

  if (!account) {
    return (
      <div className='modal-root__modal dialog-modal'>
        <LoadingIndicator />
      </div>
    );
  }

  return (
    <div className='modal-root__modal dialog-modal'>
      <div className='dialog-modal__header'>
        <IconButton
          icon='close'
          className={classes.modalCloseButton}
          onClick={onClose}
          iconComponent={CloseIcon}
          title={intl.formatMessage({
            id: 'account_fields_modal.close',
            defaultMessage: 'Close',
          })}
        />
        <span className={`${classes.modalTitle} dialog-modal__header__title`}>
          <FormattedMessage
            id='account_fields_modal.title'
            defaultMessage="{name}'s info"
            values={{
              name: <DisplayName account={account} variant='simple' />,
            }}
          />
        </span>
      </div>
      <div className='dialog-modal__content'>
        <AnimateEmojiProvider>
          <dl className={classes.modalFieldsList}>
            {account.fields.map((field, index) => (
              <div
                key={index}
                className={`${classes.modalFieldItem} ${classes.fieldCard}`}
              >
                <EmojiHTML
                  as='dt'
                  htmlString={field.name_emojified}
                  extraEmojis={account.emojis}
                  className='translate'
                  {...htmlHandlers}
                />
                <dd>
                  <EmojiHTML
                    as='span'
                    htmlString={field.value_emojified}
                    extraEmojis={account.emojis}
                    {...htmlHandlers}
                  />
                  {!!field.verified_at && (
                    <Icon
                      id='verified'
                      icon={IconVerified}
                      className={classes.fieldIconVerified}
                      noFill
                    />
                  )}
                </dd>
              </div>
            ))}
          </dl>
        </AnimateEmojiProvider>
      </div>
    </div>
  );
};
