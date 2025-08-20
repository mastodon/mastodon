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
  value?: StatusVisibility;
  onChange: (visibility: StatusVisibility) => void;
  noDirect?: boolean;
  container?: () => HTMLElement | null;
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
    meta: privacyMessages.public_long,
  },
  unlisted: {
    icon: 'unlock',
    iconComponent: QuietTimeIcon,
    value: 'unlisted',
    text: privacyMessages.unlisted_short,
    meta: privacyMessages.unlisted_long,
    extra: privacyMessages.unlisted_extra,
  },
  private: {
    icon: 'lock',
    iconComponent: LockIcon,
    value: 'private',
    text: privacyMessages.private_short,
    meta: privacyMessages.private_long,
  },
  direct: {
    icon: 'at',
    iconComponent: AlternateEmailIcon,
    value: 'direct',
    text: privacyMessages.direct_short,
    meta: privacyMessages.direct_long,
  },
};

const PrivacyModalButton: FC<PrivacyDropdownProps> = ({
  value,
  disabled = false,
}) => {
  const intl = useIntl();

  const currentVisibility = useAppSelector(
    (state) =>
      (state.compose.get('privacy') as StatusVisibility | undefined) ??
      value ??
      (state.compose.get('default_privacy') as StatusVisibility),
  );
  const currentQuotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy,
  );

  const currentIcon = useMemo(() => {
    const option = visibilityOptions[currentVisibility];
    return { icon: option.icon, iconComponent: option.iconComponent };
  }, [currentVisibility]);
  const currentText = useMemo(() => {
    const visibilityText = intl.formatMessage(
      visibilityOptions[currentVisibility].text,
    );
    if (currentVisibility === 'private' || currentVisibility === 'direct') {
      return visibilityText;
    }
    if (currentQuotePolicy !== 'public') {
      return intl.formatMessage(messages.limited_quote, {
        visibility: visibilityText,
      });
    }
    return intl.formatMessage(messages.anyone_quote, {
      visibility: visibilityText,
    });
  }, [currentQuotePolicy, currentVisibility, intl]);

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
      <Icon id={currentIcon.icon} icon={currentIcon.iconComponent} />
      <span className='dropdown-button__label'>{currentText}</span>
    </button>
  );
};
