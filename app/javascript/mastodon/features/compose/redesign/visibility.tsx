import type React from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { ChatCircleIcon } from '@phosphor-icons/react';

import {
  changeComposeVisibility,
  setComposeQuotePolicy,
} from '@/mastodon/actions/compose_typed';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Button } from '@/mastodon/components/button/redesign';
import { Fieldset, RadioButtonField } from '@/mastodon/components/form_fields';
import { ToggleField } from '@/mastodon/components/form_fields/redesign';
import { Icon } from '@/mastodon/components/icon';
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
    <div {...wrapperProps} className={classes.menu}>
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
        <RadioButtonField
          name='public'
          label={
            <FormattedMessage
              id='privacy.public.short'
              defaultMessage='Public'
            />
          }
          checked={privacy === 'public' || privacy === 'unlisted'}
          onChange={handlePrivacyChange}
          wrapperClassName={classes.menuItem}
        />
        <RadioButtonField
          name='private'
          label={
            <FormattedMessage
              id='privacy.private.short'
              defaultMessage='Followers'
            />
          }
          checked={privacy === 'private'}
          onChange={handlePrivacyChange}
          wrapperClassName={classes.menuItem}
        />
      </Fieldset>

      <hr />

      <ToggleField
        name='unlisted'
        label={
          <FormattedMessage
            id='compose.discoverable'
            defaultMessage='Discoverable in public feeds & search results'
          />
        }
        wrapperClassName={classes.menuItem}
        disabled={privacy === 'private'}
        checked={privacy === 'public'}
        onChange={handlePrivacyChange}
        size='sm'
      />

      <ToggleField
        label={
          <FormattedMessage
            id='compose.quotable'
            defaultMessage='Allow others to quote'
          />
        }
        wrapperClassName={classes.menuItem}
        disabled={privacy === 'private'}
        checked={quotePolicy === 'public' && privacy !== 'private'}
        onChange={handleQuotePolicyChange}
        size='sm'
      />

      <hr />

      <button
        type='button'
        className={classes.chatButton}
        onClick={handleSwitchToMessage}
      >
        <Icon id='chat' icon={ChatCircleIcon} />
        <FormattedMessage
          id='compose.post.to_message'
          defaultMessage='Compose a message instead'
        />
      </button>
    </div>
  );
};
