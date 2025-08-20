import type { FC, KeyboardEventHandler } from 'react';
import { useCallback, useMemo, useRef, useState } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';
import type { Placement } from 'react-overlays/esm/usePopper';

import { openModal } from '@/mastodon/actions/modal';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import { isStatusVisibility } from '@/mastodon/api_types/statuses';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isFeatureEnabled } from '@/mastodon/utils/environment';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import { DropdownSelector } from 'mastodon/components/dropdown_selector';
import { Icon } from 'mastodon/components/icon';

export const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  public_long: {
    id: 'privacy.public.long',
    defaultMessage: 'Anyone on and off Mastodon',
  },
  unlisted_short: {
    id: 'privacy.unlisted.short',
    defaultMessage: 'Quiet public',
  },
  unlisted_long: {
    id: 'privacy.unlisted.long',
    defaultMessage: 'Fewer algorithmic fanfares',
  },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  private_long: {
    id: 'privacy.private.long',
    defaultMessage: 'Only your followers',
  },
  direct_short: {
    id: 'privacy.direct.short',
    defaultMessage: 'Specific people',
  },
  direct_long: {
    id: 'privacy.direct.long',
    defaultMessage: 'Everyone mentioned in the post',
  },
  change_privacy: {
    id: 'privacy.change',
    defaultMessage: 'Change post privacy',
  },
  unlisted_extra: {
    id: 'privacy.unlisted.additional',
    defaultMessage:
      'This behaves exactly like public, except the post will not appear in live feeds or hashtags, explore, or Mastodon search, even if you are opted-in account-wide.',
  },
  anyone_quote: {
    id: 'privacy.quote.anyone',
    defaultMessage: '{visibility}, anyone can quote',
  },
  limited_quote: {
    id: 'privacy.quote.limited',
    defaultMessage: '{visibility}, quotes limited',
  },
});

const visibilityOptions = {
  public: {
    icon: 'globe',
    iconComponent: PublicIcon,
    value: 'public',
    text: messages.public_short,
    meta: messages.public_long,
  },
  unlisted: {
    icon: 'unlock',
    iconComponent: QuietTimeIcon,
    value: 'unlisted',
    text: messages.unlisted_short,
    meta: messages.unlisted_long,
    extra: messages.unlisted_extra,
  },
  private: {
    icon: 'lock',
    iconComponent: LockIcon,
    value: 'private',
    text: messages.private_short,
    meta: messages.private_long,
  },
  direct: {
    icon: 'at',
    iconComponent: AlternateEmailIcon,
    value: 'direct',
    text: messages.direct_short,
    meta: messages.direct_long,
  },
};

interface PrivacyDropdownProps {
  value?: StatusVisibility;
  onChange: (visibility: StatusVisibility) => void;
  noDirect?: boolean;
  container?: () => HTMLElement | null;
  disabled?: boolean;
}

export const PrivacyDropdown: FC<PrivacyDropdownProps> = (props) => {
  if (!isFeatureEnabled('outgoing_quotes')) {
    return <PrivacyDropdownLegacy {...props} />;
  }
  return <PrivacyDropdownModal {...props} />;
};

const PrivacyDropdownModal: FC<PrivacyDropdownProps> = ({
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
      title={intl.formatMessage(messages.change_privacy)}
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

const PrivacyDropdownLegacy: FC<PrivacyDropdownProps> = ({
  value,
  onChange,
  noDirect = false,
  container,
  disabled = false,
}) => {
  const intl = useIntl();

  const [open, setOpen] = useState(false);
  const [placement, setPlacement] = useState<Placement>('bottom');

  const options = useMemo(
    () =>
      Object.values(visibilityOptions)
        .filter((option) => !noDirect || option.value === 'direct')
        .map((option) => ({
          ...option,
          text: intl.formatMessage(option.text),
          meta: intl.formatMessage(option.meta),
          extra:
            'extra' in option ? intl.formatMessage(option.extra) : undefined,
        })),
    [intl, noDirect],
  );

  const initialVisibility = useAppSelector(
    (state) =>
      value ?? (state.compose.get('default_privacy') as StatusVisibility),
  );
  const valueOption = options.find((item) => item.value === initialVisibility);

  const targetRef = useRef<HTMLDivElement>(null);
  const activeElementRef = useRef<Element | null>(null);

  const handleToggle = useCallback(() => {
    if (open && activeElementRef.current instanceof HTMLElement) {
      activeElementRef.current.focus({ preventScroll: true });
    }

    setOpen((curOpen) => !curOpen);
  }, [open]);

  const handleMouseDown = useCallback(() => {
    if (!open) {
      activeElementRef.current = document.activeElement;
    }
  }, [open]);

  const handleButtonKeyDown: KeyboardEventHandler = useCallback(
    (e) => {
      switch (e.key) {
        case ' ':
        case 'Enter':
          handleMouseDown();
          break;
      }
    },
    [handleMouseDown],
  );

  const handleClose = useCallback(() => {
    if (open && activeElementRef.current instanceof HTMLElement) {
      activeElementRef.current.focus({ preventScroll: true });
    }
    setOpen(false);
  }, [open]);

  const handleKeyDown: KeyboardEventHandler = useCallback(
    (e) => {
      switch (e.key) {
        case 'Escape':
          handleClose();
          break;
      }
    },
    [handleClose],
  );

  const handleChange = useCallback(
    (newValue: string) => {
      if (isStatusVisibility(newValue)) {
        onChange(newValue);
      }
    },
    [onChange],
  );

  const handleOverlayEnter = useCallback((state: { placement?: Placement }) => {
    if (state.placement) {
      setPlacement(state.placement);
    }
  }, []);

  return (
    // eslint-disable-next-line jsx-a11y/no-static-element-interactions
    <div ref={targetRef} onKeyDown={handleKeyDown}>
      <button
        type='button'
        title={intl.formatMessage(messages.change_privacy)}
        aria-expanded={open}
        onClick={handleToggle}
        onMouseDown={handleMouseDown}
        onKeyDown={handleButtonKeyDown}
        disabled={disabled}
        className={classNames('dropdown-button', { active: open })}
      >
        {valueOption ? (
          <>
            <Icon id={valueOption.icon} icon={valueOption.iconComponent} />
            <span className='dropdown-button__label'>{valueOption.text}</span>
          </>
        ) : (
          // This shouldn't happen, it's just for TS completeness.
          <FormattedMessage
            id='privacy.unknown_label'
            defaultMessage='Unknown privacy'
          />
        )}
      </button>

      <Overlay
        show={open}
        offset={[5, 5]}
        placement={placement}
        flip
        target={targetRef.current}
        container={container}
        popperConfig={{
          strategy: 'fixed',
          onFirstUpdate: handleOverlayEnter,
        }}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
              className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}
            >
              <DropdownSelector
                items={options}
                value={initialVisibility}
                onClose={handleClose}
                onChange={handleChange}
              />
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};
