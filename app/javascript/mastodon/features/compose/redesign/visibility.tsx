import type React from 'react';
import { useCallback, useRef, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  ChatCircleIcon,
  CheckIcon,
  MagnifyingGlassIcon,
  QuotesIcon,
} from '@phosphor-icons/react';

import {
  changeComposeVisibility,
  setComposeQuotePolicy,
} from '@/mastodon/actions/compose_typed';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Button } from '@/mastodon/components/button/redesign';
import {
  Dropdown,
  DropdownItem,
  DropdownItemButton,
} from '@/mastodon/components/dropdown/redesign';
import { Fieldset } from '@/mastodon/components/form_fields';
import {
  ToggleField,
  RadioButtonField,
} from '@/mastodon/components/form_fields/redesign';
import type { IconProp } from '@/mastodon/components/icon';
import { Popover } from '@/mastodon/components/popover';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectComposePrivacy } from './selectors';
import classes from './styles.module.scss';

export const ComposeVisibility: React.FC = () => {
  const privacy = useAppSelector(selectComposePrivacy);
  const [trigger, setTrigger] = useState<HTMLElement | null>(null);
  const [showMenu, { onToggle, onFalse }] = useToggle();

  return (
    <>
      <FormattedMessage
        id='compose.post.to'
        defaultMessage='To: {button}'
        values={{
          button: (
            <Button
              className={classes.toolbarGrow}
              size='sm'
              onClick={onToggle}
              ref={setTrigger}
            >
              {privacy !== 'private' && (
                <FormattedMessage
                  id='privacy.public.short'
                  defaultMessage='Public'
                />
              )}
              {privacy === 'private' && (
                <FormattedMessage
                  id='privacy.private.short'
                  defaultMessage='Followers'
                />
              )}
            </Button>
          ),
        }}
      />
      <Popover
        isOpen={showMenu}
        onClose={onFalse}
        reference={trigger}
        placement='bottom-start'
        offset={4}
      >
        {({ props }) => <ComposeVisibilityMenu {...props} />}
      </Popover>
    </>
  );
};

const ComposeVisibilityMenu: React.FC<Record<string, unknown>> = (
  wrapperProps,
) => {
  const privacy = useAppSelector(selectComposePrivacy);
  const defaultPrivacy = useAppSelector(
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );
  const quotePolicy = useAppSelector(
    (state) =>
      (state.compose.get('quote_policy') as ApiQuotePolicy | undefined) ??
      (state.compose.get('default_quote_policy') as ApiQuotePolicy),
  );

  const dispatch = useAppDispatch();
  const handlePrivacyChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        const { name } = event.target;
        if (name === 'private' && privacy !== 'private') {
          dispatch(changeComposeVisibility(name));
        } else if (name === 'public' && privacy === 'private') {
          dispatch(
            changeComposeVisibility(
              defaultPrivacy === 'unlisted' ? 'unlisted' : 'public',
            ),
          );
        } else if (name === 'unlisted' && privacy !== 'private') {
          dispatch(
            changeComposeVisibility(
              privacy === 'public' ? 'unlisted' : 'public',
            ),
          );
        }
      },
      [defaultPrivacy, dispatch, privacy],
    );
  const handleQuotePolicyChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        const checked = event.target.checked;
        dispatch(setComposeQuotePolicy(checked ? 'public' : 'nobody'));
      },
      [dispatch],
    );
  const handleSwitchToMessage: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(changeComposeVisibility('direct'));
    }, [dispatch]);

  return (
    <Dropdown {...wrapperProps} maxWidth={280}>
      <Fieldset
        name='visibility'
        legend={
          <FormattedMessage
            id='compose.visibility.title'
            defaultMessage='Visibility'
          />
        }
        className={classes.visibilityFieldset}
      >
        <DropdownRadioCheckField
          name='public'
          checked={privacy === 'public' || privacy === 'unlisted'}
          onChange={handlePrivacyChange}
        >
          <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
        </DropdownRadioCheckField>

        <DropdownRadioCheckField
          name='private'
          checked={privacy === 'private'}
          onChange={handlePrivacyChange}
        >
          <FormattedMessage
            id='privacy.private.short'
            defaultMessage='Followers'
          />
        </DropdownRadioCheckField>
      </Fieldset>

      <hr />

      <DropdownToggleField
        name='unlisted'
        disabled={privacy === 'private'}
        checked={privacy === 'public'}
        onChange={handlePrivacyChange}
        icon={MagnifyingGlassIcon}
      >
        <FormattedMessage
          id='compose.discoverable'
          defaultMessage='Discoverable in public feeds & search results'
        />
      </DropdownToggleField>

      <DropdownToggleField
        disabled={privacy === 'private'}
        checked={quotePolicy === 'public' && privacy !== 'private'}
        onChange={handleQuotePolicyChange}
        icon={QuotesIcon}
      >
        <FormattedMessage
          id='compose.quotable'
          defaultMessage='Allow others to quote'
        />
      </DropdownToggleField>

      <hr />

      <DropdownItemButton
        leadingIcon={ChatCircleIcon}
        onClick={handleSwitchToMessage}
      >
        <FormattedMessage
          id='compose.post.to_message'
          defaultMessage='Compose a message instead'
        />
      </DropdownItemButton>
    </Dropdown>
  );
};

const DropdownRadioCheckField: React.FC<
  Omit<
    React.ComponentProps<typeof RadioButtonField>,
    'label' | 'icon' | 'iconClassName'
  > & {
    children: React.ReactNode;
  }
> = ({ children, onClick, ...props }) => {
  const { ref, onWrapperClick } = useDropdownControl();

  return (
    <DropdownItem onClick={onWrapperClick}>
      <RadioButtonField
        {...props}
        ref={ref}
        label={children}
        icon={CheckIcon}
        wrapperClassName={classes.dropdownItemControl}
      />
    </DropdownItem>
  );
};

const DropdownToggleField: React.FC<
  Omit<React.ComponentProps<typeof ToggleField>, 'label'> & {
    children: React.ReactNode;
    icon?: IconProp;
  }
> = ({ children, icon, ...props }) => {
  const { ref, onWrapperClick } = useDropdownControl();

  return (
    <DropdownItem onClick={onWrapperClick} leadingIcon={icon}>
      <ToggleField
        size='sm'
        {...props}
        ref={ref}
        label={children}
        wrapperClassName={classes.dropdownItemControl}
      />
    </DropdownItem>
  );
};

function useDropdownControl() {
  const ref = useRef<HTMLInputElement | null>(null);
  const onWrapperClick: React.MouseEventHandler = useCallback((event) => {
    const { target } = event;
    if (
      target instanceof HTMLLabelElement ||
      target instanceof HTMLInputElement
    ) {
      return;
    }
    ref.current?.click();
  }, []);
  return { ref, onWrapperClick };
}
