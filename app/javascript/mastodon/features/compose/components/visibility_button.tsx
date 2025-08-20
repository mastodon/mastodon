import { useCallback, useMemo } from 'react';
import type { KeyboardEventHandler, FC } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { openModal } from '@/mastodon/actions/modal';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Icon } from '@/mastodon/components/icon';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';
import { isFeatureEnabled } from '@/mastodon/utils/environment';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';

import { messages as privacyMessages } from './privacy_dropdown';

const messages = defineMessages({
  anyone_quote: {
    id: 'privacy.quote.anyone',
    defaultMessage: '{visibility}, anyone can quote',
  },
  limited_quote: {
    id: 'privacy.quote.limited',
    defaultMessage: '{visibility}, quotes limited',
  },
});

interface PrivacyDropdownProps {
  disabled?: boolean;
}

export const VisibilityButton: FC<PrivacyDropdownProps> = (props) => {
  if (!isFeatureEnabled('outgoing_quotes')) {
    return <PrivacyDropdownContainer {...props} />;
  }
  return <PrivacyModalButton {...props} />;
};

const visibilityOptions = {
  public: {
    icon: 'globe',
    iconComponent: PublicIcon,
    value: 'public',
    text: privacyMessages.public_short,
  },
  unlisted: {
    icon: 'unlock',
    iconComponent: QuietTimeIcon,
    value: 'unlisted',
    text: privacyMessages.unlisted_short,
  },
  private: {
    icon: 'lock',
    iconComponent: LockIcon,
    value: 'private',
    text: privacyMessages.private_short,
  },
  direct: {
    icon: 'at',
    iconComponent: AlternateEmailIcon,
    value: 'direct',
    text: privacyMessages.direct_short,
  },
};

const PrivacyModalButton: FC<PrivacyDropdownProps> = ({ disabled = false }) => {
  const intl = useIntl();

  const { visibility, quotePolicy } = useAppSelector((state) => ({
    visibility: state.compose.get('privacy') as StatusVisibility,
    quotePolicy: state.compose.get('quote_policy') as ApiQuotePolicy,
  }));

  const { icon, iconComponent } = useMemo(() => {
    const option = visibilityOptions[visibility];
    return { icon: option.icon, iconComponent: option.iconComponent };
  }, [visibility]);
  const text = useMemo(() => {
    const visibilityText = intl.formatMessage(
      visibilityOptions[visibility].text,
    );
    if (visibility === 'private' || visibility === 'direct') {
      return visibilityText;
    }
    if (quotePolicy !== 'public') {
      return intl.formatMessage(messages.limited_quote, {
        visibility: visibilityText,
      });
    }
    return intl.formatMessage(messages.anyone_quote, {
      visibility: visibilityText,
    });
  }, [quotePolicy, visibility, intl]);

  const dispatch = useAppDispatch();
  const handleOpen = useCallback(() => {
    dispatch(openModal({ modalType: 'COMPOSE_PRIVACY', modalProps: {} }));
  }, [dispatch]);
  const handleKeyDown: KeyboardEventHandler = useCallback(
    (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        handleOpen();
        event.preventDefault();
      }
    },
    [handleOpen],
  );

  return (
    <button
      type='button'
      title={intl.formatMessage(privacyMessages.change_privacy)}
      onClick={handleOpen}
      onKeyDown={handleKeyDown}
      disabled={disabled}
      className={classNames('dropdown-button')}
    >
      <Icon id={icon} icon={iconComponent} />
      <span className='dropdown-button__label'>{text}</span>
    </button>
  );
};
