import { useCallback, useMemo, useRef, useState } from 'react';
import type { FC } from 'react';

import type { IntlShape } from 'react-intl';
import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/esm/Overlay';
import type { Placement } from 'react-overlays/esm/usePopper';

import {
  changeComposeVisibility,
  setComposeQuotePolicy,
} from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { DropdownSelector } from '@/mastodon/components/dropdown_selector';
import { Icon } from '@/mastodon/components/icon';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import ArrowDropDown from '@/material-icons/400-24px/arrow_drop_down.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import type { VisibilityModalCallback } from '../../ui/components/visibility_modal';

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
  disabled_quote: {
    id: 'privacy.quote.disabled',
    defaultMessage: '{visibility}, quotes disabled',
  },
});

interface PrivacyDropdownProps {
  disabled?: boolean;
}

export const VisibilityButton: FC<PrivacyDropdownProps> = (props) => {
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

const shortMessageFromSettings = (
  intl: IntlShape,
  visibility: StatusVisibility,
  quotePolicy: ApiQuotePolicy,
) => {
  const visibilityText = intl.formatMessage(visibilityOptions[visibility].text);
  if (visibility === 'private' || visibility === 'direct') {
    return visibilityText;
  }
  if (quotePolicy === 'nobody') {
    return intl.formatMessage(messages.disabled_quote, {
      visibility: visibilityText,
    });
  }
  if (quotePolicy !== 'public') {
    return intl.formatMessage(messages.limited_quote, {
      visibility: visibilityText,
    });
  }
  return intl.formatMessage(messages.anyone_quote, {
    visibility: visibilityText,
  });
};

const PrivacyPresetsDropdown: FC<PrivacyDropdownProps> = ({
  disabled = false,
}) => {
  const intl = useIntl();

  const dispatch = useAppDispatch();

  const targetRef = useRef<HTMLButtonElement>(null);
  const [open, setOpen] = useState<boolean>(false);
  const [placement, setPlacement] = useState<Placement>('bottom');

  const visibility = useAppSelector(
    (state) => state.compose.get('privacy') as StatusVisibility,
  );
  const defaultQuotePolicy = useAppSelector(
    (state) => state.compose.get('default_quote_policy') as ApiQuotePolicy,
  );

  const handleOverlayEnter = useCallback(
    ({ placement }: { placement?: Placement }) => {
      if (placement) setPlacement(placement);
    },
    [setPlacement],
  );

  const handleToggle = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  const handleClose = useCallback(() => {
    setOpen(false);
  }, [setOpen]);

  const handlePresetChange = useCallback(
    (value: string) => {
      switch (value) {
        case 'public':
          dispatch(changeComposeVisibility('public'));
          dispatch(setComposeQuotePolicy(defaultQuotePolicy));
          break;
        case 'unlisted':
          dispatch(changeComposeVisibility('unlisted'));
          dispatch(
            setComposeQuotePolicy(
              defaultQuotePolicy === 'nobody' ? 'nobody' : 'followers',
            ),
          );
          break;
        case 'private':
          dispatch(changeComposeVisibility('private'));
          dispatch(setComposeQuotePolicy('nobody'));
          break;
        case 'direct':
          dispatch(changeComposeVisibility('direct'));
          dispatch(setComposeQuotePolicy('nobody'));
          break;
      }
    },
    [dispatch, defaultQuotePolicy],
  );

  const options = useMemo(
    () => [
      {
        icon: 'globe',
        iconComponent: PublicIcon,
        value: 'public',
        text: shortMessageFromSettings(intl, 'public', defaultQuotePolicy),
        meta: 'Anyone and on off Mastodon',
      },
      {
        icon: 'unlock',
        iconComponent: QuietTimeIcon,
        value: 'unlisted',
        text: shortMessageFromSettings(
          intl,
          'unlisted',
          defaultQuotePolicy === 'nobody' ? 'nobody' : 'followers',
        ),
        meta: 'Hidden from Mastodon search results, trending, and public timelines',
      },
      {
        icon: 'lock',
        iconComponent: LockIcon,
        value: 'private',
        text: shortMessageFromSettings(intl, 'private', 'nobody'),
        meta: 'Only your followers',
      },
      {
        icon: 'at',
        iconComponent: AlternateEmailIcon,
        value: 'direct',
        text: shortMessageFromSettings(intl, 'direct', 'nobody'),
        meta: 'Everyone mentioned in the post',
      },
    ],
    [intl, defaultQuotePolicy],
  );

  return (
    <>
      <button
        type='button'
        className={classNames('dropdown-button', { active: open })}
        onClick={handleToggle}
        disabled={disabled}
        ref={targetRef}
      >
        <Icon id='down-arrow' icon={ArrowDropDown} />
      </button>
      <Overlay
        show={open}
        offset={[5, 5]}
        placement={placement}
        flip
        target={targetRef}
        popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
              className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}
            >
              <DropdownSelector
                header={
                  <h4>
                    <FormattedMessage
                      id='privacy.quick_settings_presets'
                      defaultMessage='Quick settings presets'
                    />
                  </h4>
                }
                items={options}
                value={visibility}
                onClose={handleClose}
                onChange={handlePresetChange}
              />
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};

const PrivacyModalButton: FC<PrivacyDropdownProps> = ({ disabled = false }) => {
  const intl = useIntl();

  const quotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy,
  );
  const visibility = useAppSelector(
    (state) => state.compose.get('privacy') as StatusVisibility,
  );

  const { icon, iconComponent } = useMemo(() => {
    const option = visibilityOptions[visibility];
    return { icon: option.icon, iconComponent: option.iconComponent };
  }, [visibility]);
  const text = useMemo(() => {
    return shortMessageFromSettings(intl, visibility, quotePolicy);
  }, [quotePolicy, visibility, intl]);

  const dispatch = useAppDispatch();

  const handleChange: VisibilityModalCallback = useCallback(
    (newVisibility, newQuotePolicy) => {
      if (newVisibility !== visibility) {
        dispatch(changeComposeVisibility(newVisibility));
      }
      if (newQuotePolicy !== quotePolicy) {
        dispatch(setComposeQuotePolicy(newQuotePolicy));
      }
    },
    [dispatch, quotePolicy, visibility],
  );

  const handleOpen = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'COMPOSE_PRIVACY',
        modalProps: { onChange: handleChange },
      }),
    );
  }, [dispatch, handleChange]);

  return (
    <div className='split-button'>
      <button
        type='button'
        title={intl.formatMessage(privacyMessages.change_privacy)}
        onClick={handleOpen}
        disabled={disabled}
        className={classNames('dropdown-button')}
      >
        <Icon id={icon} icon={iconComponent} />
        <span className='dropdown-button__label'>{text}</span>
      </button>
      <PrivacyPresetsDropdown disabled={disabled} />
    </div>
  );
};
