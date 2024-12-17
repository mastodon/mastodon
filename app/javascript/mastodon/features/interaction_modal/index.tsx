import { useCallback, useEffect, useState, useRef } from 'react';

import { FormattedMessage, defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { escapeRegExp } from 'lodash';
import { useDebouncedCallback } from 'use-debounce';

import InsertChartIcon from '@/material-icons/400-24px/insert_chart.svg?react';
import PersonAddIcon from '@/material-icons/400-24px/person_add.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import ReplyIcon from '@/material-icons/400-24px/reply.svg?react';
import StarIcon from '@/material-icons/400-24px/star.svg?react';
import { openModal, closeModal } from 'mastodon/actions/modal';
import { apiRequest } from 'mastodon/api';
import { Button } from 'mastodon/components/button';
import { Icon } from 'mastodon/components/icon';
import {
  domain as localDomain,
  registrationsOpen,
  sso_redirect,
} from 'mastodon/initial_state';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  loginPrompt: {
    id: 'interaction_modal.username_prompt',
    defaultMessage: 'E.g. {example}',
  },
});

interface LoginFormMessage {
  type:
    | 'fetchInteractionURL'
    | 'fetchInteractionURL-failure'
    | 'fetchInteractionURL-success';
  uri_or_domain: string;
  template?: string;
}

const PERSISTENCE_KEY = 'mastodon_home';

const EXAMPLE_VALUE = 'username@mastodon.social';

const isValidDomain = (value: string) => {
  const url = new URL('https:///path');
  url.hostname = value;
  return url.hostname === value;
};

const valueToDomain = (value: string): string | null => {
  // If the user starts typing an URL
  if (/^https?:\/\//.test(value)) {
    try {
      const url = new URL(value);

      return url.host;
    } catch {
      return null;
    }
    // If the user writes their full handle including username
  } else if (value.includes('@')) {
    const [_, domain, ...other] = value.replace(/^@/, '').split('@');

    if (!domain || other.length > 0) {
      return null;
    }

    return valueToDomain(domain);
  }

  return value;
};

const addInputToOptions = (value: string, options: string[]) => {
  value = value.trim();

  if (value.includes('.') && isValidDomain(value)) {
    return [value].concat(options.filter((x) => x !== value));
  }

  return options;
};

const isValueValid = (value: string) => {
  let likelyAcct = false;
  let url = null;

  if (value.startsWith('/')) {
    return false;
  }

  if (value.startsWith('@')) {
    value = value.slice(1);
    likelyAcct = true;
  }

  // The user is in the middle of typing something, do not error out
  if (value === '') {
    return true;
  }

  if (/^https?:\/\//.test(value) && !likelyAcct) {
    url = value;
  } else {
    url = `https://${value}`;
  }

  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

const sendToFrame = (frame: HTMLIFrameElement | null, value: string): void => {
  if (valueToDomain(value.trim()) === localDomain) {
    window.location.href = '/auth/sign_in';
    return;
  }

  frame?.contentWindow?.postMessage(
    {
      type: 'fetchInteractionURL',
      uri_or_domain: value.trim(),
    },
    window.origin,
  );
};

const LoginForm: React.FC<{
  resourceUrl: string;
}> = ({ resourceUrl }) => {
  const intl = useIntl();
  const [value, setValue] = useState(
    localStorage.getItem(PERSISTENCE_KEY) ?? '',
  );
  const [expanded, setExpanded] = useState(false);
  const [selectedOption, setSelectedOption] = useState(-1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState(false);
  const [options, setOptions] = useState<string[]>([]);
  const [networkOptions, setNetworkOptions] = useState<string[]>([]);
  const [valueChanged, setValueChanged] = useState(false);

  const inputRef = useRef<HTMLInputElement>(null);
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const searchRequestRef = useRef<AbortController | null>(null);

  useEffect(() => {
    const handleMessage = (event: MessageEvent<LoginFormMessage>) => {
      if (
        event.origin !== window.origin ||
        event.source !== iframeRef.current?.contentWindow
      ) {
        return;
      }

      if (event.data.type === 'fetchInteractionURL-failure') {
        setIsSubmitting(false);
        setError(true);
      } else if (event.data.type === 'fetchInteractionURL-success') {
        if (event.data.template && /^https?:\/\//.test(event.data.template)) {
          try {
            const url = new URL(
              event.data.template.replace(
                '{uri}',
                encodeURIComponent(resourceUrl),
              ),
            );

            localStorage.setItem(PERSISTENCE_KEY, event.data.uri_or_domain);

            window.location.href = url.toString();
          } catch {
            setIsSubmitting(false);
            setError(true);
          }
        } else {
          setIsSubmitting(false);
          setError(true);
        }
      }
    };

    window.addEventListener('message', handleMessage);

    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, [resourceUrl, setIsSubmitting, setError]);

  const handleSearch = useDebouncedCallback(
    (value: string) => {
      if (searchRequestRef.current) {
        searchRequestRef.current.abort();
      }

      const domain = valueToDomain(value.trim());

      if (domain === null || domain.length === 0) {
        setOptions([]);
        setNetworkOptions([]);
        return;
      }

      searchRequestRef.current = new AbortController();

      void apiRequest<string[] | null>('GET', 'v1/peers/search', {
        signal: searchRequestRef.current.signal,
        params: {
          q: domain,
        },
      })
        .then((data) => {
          setNetworkOptions(data ?? []);
          setOptions(addInputToOptions(value, data ?? []));
          return '';
        })
        .catch(() => {
          // Nothing
        });
    },
    500,
    { leading: true, trailing: true },
  );

  const handleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setValue(value);
      setValueChanged(true);
      setError(!isValueValid(value));
      setOptions(addInputToOptions(value, networkOptions));
      handleSearch(value);
    },
    [
      setError,
      setValue,
      setValueChanged,
      setOptions,
      networkOptions,
      handleSearch,
    ],
  );

  const handleSubmit = useCallback(() => {
    setIsSubmitting(true);
    sendToFrame(iframeRef.current, value);
  }, [setIsSubmitting, value]);

  const handleFocus = useCallback(() => {
    setExpanded(true);
  }, [setExpanded]);

  const handleBlur = useCallback(() => {
    setExpanded(false);
  }, [setExpanded]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      const selectedOptionValue = options[selectedOption];

      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();

          if (options.length > 0) {
            setSelectedOption((selectedOption) =>
              Math.min(selectedOption + 1, options.length - 1),
            );
          }

          break;
        case 'ArrowUp':
          e.preventDefault();

          if (options.length > 0) {
            setSelectedOption((selectedOption) =>
              Math.max(selectedOption - 1, -1),
            );
          }

          break;
        case 'Enter':
          e.preventDefault();

          if (selectedOption === -1) {
            handleSubmit();
          } else if (options.length > 0 && selectedOptionValue) {
            setError(false);
            setValue(selectedOptionValue);
            setIsSubmitting(true);
            sendToFrame(iframeRef.current, selectedOptionValue);
          }

          break;
      }
    },
    [
      handleSubmit,
      setSelectedOption,
      setError,
      setValue,
      selectedOption,
      options,
    ],
  );

  const handleOptionClick = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();

      const index = Number(e.currentTarget.getAttribute('data-index'));
      const option = options[index];

      if (!option) {
        return;
      }

      setSelectedOption(index);
      setValue(option);
      setError(false);
      setIsSubmitting(true);
      sendToFrame(iframeRef.current, option);
    },
    [options, setSelectedOption, setValue, setError],
  );

  const domain = (valueToDomain(value) ?? '').trim();
  const domainRegExp = new RegExp(`(${escapeRegExp(domain)})`, 'gi');
  const hasPopOut = valueChanged && domain.length > 0 && options.length > 0;

  return (
    <div
      className={classNames('interaction-modal__login', {
        focused: expanded,
        expanded: hasPopOut,
        invalid: error,
      })}
    >
      <iframe
        ref={iframeRef}
        style={{ display: 'none' }}
        src='/remote_interaction_helper'
        sandbox='allow-scripts allow-same-origin'
        title='remote interaction helper'
      />

      <div className='interaction-modal__login__input'>
        <input
          ref={inputRef}
          type='text'
          value={value}
          placeholder={intl.formatMessage(messages.loginPrompt, {
            example: EXAMPLE_VALUE,
          })}
          aria-label={intl.formatMessage(messages.loginPrompt, {
            example: EXAMPLE_VALUE,
          })}
          // eslint-disable-next-line jsx-a11y/no-autofocus
          autoFocus
          onChange={handleChange}
          onFocus={handleFocus}
          onBlur={handleBlur}
          onKeyDown={handleKeyDown}
          autoComplete='off'
          autoCapitalize='off'
          spellCheck='false'
        />

        <Button onClick={handleSubmit} disabled={isSubmitting || error}>
          <FormattedMessage id='interaction_modal.go' defaultMessage='Go' />
        </Button>
      </div>

      {hasPopOut && (
        <div className='search__popout'>
          <div className='search__popout__menu'>
            {options.map((option, i) => (
              <button
                key={option}
                onMouseDown={handleOptionClick}
                data-index={i}
                className={classNames('search__popout__menu__item', {
                  selected: selectedOption === i,
                })}
              >
                {option
                  .split(domainRegExp)
                  .map((part, i) =>
                    part.toLowerCase() === domain.toLowerCase() ? (
                      <mark key={i}>{part}</mark>
                    ) : (
                      <span key={i}>{part}</span>
                    ),
                  )}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

const InteractionModal: React.FC<{
  accountId: string;
  url: string;
  type: 'reply' | 'reblog' | 'favourite' | 'follow' | 'vote';
}> = ({ accountId, url, type }) => {
  const dispatch = useAppDispatch();
  const displayNameHtml = useAppSelector(
    (state) => state.accounts.get(accountId)?.display_name_html ?? '',
  );
  const signupUrl = useAppSelector(
    (state) =>
      (state.server.getIn(['server', 'registrations', 'url'], null) ||
        '/auth/sign_up') as string,
  );
  const name = <bdi dangerouslySetInnerHTML={{ __html: displayNameHtml }} />;

  const handleSignupClick = useCallback(() => {
    dispatch(
      closeModal({
        modalType: undefined,
        ignoreFocus: false,
      }),
    );

    dispatch(
      openModal({
        modalType: 'CLOSED_REGISTRATIONS',
        modalProps: {},
      }),
    );
  }, [dispatch]);

  let title: React.ReactNode,
    icon: React.ReactNode,
    actionPrompt: React.ReactNode;

  switch (type) {
    case 'reply':
      icon = <Icon id='reply' icon={ReplyIcon} />;
      title = (
        <FormattedMessage
          id='interaction_modal.title.reply'
          defaultMessage="Reply to {name}'s post"
          values={{ name }}
        />
      );
      actionPrompt = (
        <FormattedMessage
          id='interaction_modal.action.reply'
          defaultMessage='To continue, you need to reply from your account.'
        />
      );
      break;
    case 'reblog':
      icon = <Icon id='retweet' icon={RepeatIcon} />;
      title = (
        <FormattedMessage
          id='interaction_modal.title.reblog'
          defaultMessage="Boost {name}'s post"
          values={{ name }}
        />
      );
      actionPrompt = (
        <FormattedMessage
          id='interaction_modal.action.reblog'
          defaultMessage='To continue, you need to reblog from your account.'
        />
      );
      break;
    case 'favourite':
      icon = <Icon id='star' icon={StarIcon} />;
      title = (
        <FormattedMessage
          id='interaction_modal.title.favourite'
          defaultMessage="Favorite {name}'s post"
          values={{ name }}
        />
      );
      actionPrompt = (
        <FormattedMessage
          id='interaction_modal.action.favourite'
          defaultMessage='To continue, you need to favorite from your account.'
        />
      );
      break;
    case 'follow':
      icon = <Icon id='user-plus' icon={PersonAddIcon} />;
      title = (
        <FormattedMessage
          id='interaction_modal.title.follow'
          defaultMessage='Follow {name}'
          values={{ name }}
        />
      );
      actionPrompt = (
        <FormattedMessage
          id='interaction_modal.action.follow'
          defaultMessage='To continue, you need to follow from your account.'
        />
      );
      break;
    case 'vote':
      icon = <Icon id='tasks' icon={InsertChartIcon} />;
      title = (
        <FormattedMessage
          id='interaction_modal.title.vote'
          defaultMessage="Vote in {name}'s poll"
          values={{ name }}
        />
      );
      actionPrompt = (
        <FormattedMessage
          id='interaction_modal.action.vote'
          defaultMessage='To continue, you need to vote from your account.'
        />
      );
      break;
  }

  let signupButton;

  if (sso_redirect) {
    signupButton = (
      <a href={sso_redirect} data-method='post' className='link-button'>
        <FormattedMessage
          id='sign_in_banner.create_account'
          defaultMessage='Create account'
        />
      </a>
    );
  } else if (registrationsOpen) {
    signupButton = (
      <a href={signupUrl} className='link-button'>
        <FormattedMessage
          id='sign_in_banner.create_account'
          defaultMessage='Create account'
        />
      </a>
    );
  } else {
    signupButton = (
      <button className='link-button' onClick={handleSignupClick}>
        <FormattedMessage
          id='sign_in_banner.create_account'
          defaultMessage='Create account'
        />
      </button>
    );
  }

  return (
    <div className='modal-root__modal interaction-modal'>
      <div className='interaction-modal__lead'>
        <h3>
          <span className='interaction-modal__icon'>{icon}</span> {title}
        </h3>
        <p>{actionPrompt}</p>
      </div>

      <LoginForm resourceUrl={url} />

      <p>
        <FormattedMessage
          id='interaction_modal.no_account_yet'
          defaultMessage="Don't have an account yet?"
        />{' '}
        {signupButton}
      </p>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export
export default InteractionModal;
