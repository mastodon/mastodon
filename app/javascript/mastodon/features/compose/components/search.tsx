import { useCallback, useState, useRef } from 'react';

import {
  defineMessages,
  useIntl,
  FormattedMessage,
  FormattedList,
} from 'react-intl';

import classNames from 'classnames';
import { useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import CancelIcon from '@/material-icons/400-24px/cancel-fill.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import {
  clickSearchResult,
  forgetSearchResult,
  openURL,
} from 'mastodon/actions/search';
import { Icon } from 'mastodon/components/icon';
import { useIdentity } from 'mastodon/identity_context';
import { domain, searchEnabled } from 'mastodon/initial_state';
import type { RecentSearch, SearchType } from 'mastodon/models/search';
import { useAppSelector, useAppDispatch } from 'mastodon/store';
import { HASHTAG_REGEX } from 'mastodon/utils/hashtags';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' },
  placeholderSignedIn: {
    id: 'search.search_or_paste',
    defaultMessage: 'Search or paste URL',
  },
});

const labelForRecentSearch = (search: RecentSearch) => {
  switch (search.type) {
    case 'account':
      return `@${search.q}`;
    case 'hashtag':
      return `#${search.q}`;
    default:
      return search.q;
  }
};

const unfocus = () => {
  document.querySelector('.ui')?.parentElement?.focus();
};

interface SearchOption {
  key: string;
  label: React.ReactNode;
  action: (e: React.MouseEvent | React.KeyboardEvent) => void;
  forget?: (e: React.MouseEvent | React.KeyboardEvent) => void;
}

export const Search: React.FC<{
  singleColumn: boolean;
  initialValue?: string;
}> = ({ singleColumn, initialValue }) => {
  const intl = useIntl();
  const recent = useAppSelector((state) => state.search.recent);
  const { signedIn } = useIdentity();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const searchInputRef = useRef<HTMLInputElement>(null);
  const [value, setValue] = useState(initialValue ?? '');
  const hasValue = value.length > 0;
  const [expanded, setExpanded] = useState(false);
  const [selectedOption, setSelectedOption] = useState(-1);
  const [quickActions, setQuickActions] = useState<SearchOption[]>([]);
  const searchOptions: SearchOption[] = [];

  if (searchEnabled) {
    searchOptions.push(
      {
        key: 'prompt-has',
        label: (
          <>
            <mark>has:</mark>{' '}
            <FormattedList
              type='disjunction'
              value={['media', 'poll', 'embed']}
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('has:');
        },
      },
      {
        key: 'prompt-is',
        label: (
          <>
            <mark>is:</mark>{' '}
            <FormattedList type='disjunction' value={['reply', 'sensitive']} />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('is:');
        },
      },
      {
        key: 'prompt-language',
        label: (
          <>
            <mark>language:</mark>{' '}
            <FormattedMessage
              id='search_popout.language_code'
              defaultMessage='ISO language code'
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('language:');
        },
      },
      {
        key: 'prompt-from',
        label: (
          <>
            <mark>from:</mark>{' '}
            <FormattedMessage id='search_popout.user' defaultMessage='user' />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('from:');
        },
      },
      {
        key: 'prompt-before',
        label: (
          <>
            <mark>before:</mark>{' '}
            <FormattedMessage
              id='search_popout.specific_date'
              defaultMessage='specific date'
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('before:');
        },
      },
      {
        key: 'prompt-during',
        label: (
          <>
            <mark>during:</mark>{' '}
            <FormattedMessage
              id='search_popout.specific_date'
              defaultMessage='specific date'
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('during:');
        },
      },
      {
        key: 'prompt-after',
        label: (
          <>
            <mark>after:</mark>{' '}
            <FormattedMessage
              id='search_popout.specific_date'
              defaultMessage='specific date'
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('after:');
        },
      },
      {
        key: 'prompt-in',
        label: (
          <>
            <mark>in:</mark>{' '}
            <FormattedList
              type='disjunction'
              value={['all', 'library', 'public']}
            />
          </>
        ),
        action: (e) => {
          e.preventDefault();
          insertText('in:');
        },
      },
    );
  }

  const recentOptions: SearchOption[] = recent.map((search) => ({
    key: `${search.type}/${search.q}`,
    label: labelForRecentSearch(search),
    action: () => {
      setValue(search.q);

      if (search.type === 'account') {
        history.push(`/@${search.q}`);
      } else if (search.type === 'hashtag') {
        history.push(`/tags/${search.q}`);
      } else {
        const queryParams = new URLSearchParams({ q: search.q });
        if (search.type) queryParams.set('type', search.type);
        history.push({ pathname: '/search', search: queryParams.toString() });
      }

      unfocus();
    },
    forget: (e) => {
      e.stopPropagation();
      void dispatch(forgetSearchResult(search.q));
    },
  }));

  const navigableOptions = hasValue
    ? quickActions.concat(searchOptions)
    : recentOptions.concat(quickActions, searchOptions);

  const insertText = (text: string) => {
    setValue((currentValue) => {
      if (currentValue === '') {
        return text;
      } else if (currentValue.endsWith(' ')) {
        return `${currentValue}${text}`;
      } else {
        return `${currentValue} ${text}`;
      }
    });
  };

  const submit = useCallback(
    (q: string, type?: SearchType) => {
      void dispatch(clickSearchResult({ q, type }));
      const queryParams = new URLSearchParams({ q });
      if (type) queryParams.set('type', type);
      history.push({ pathname: '/search', search: queryParams.toString() });
      unfocus();
    },
    [dispatch, history],
  );

  const handleChange = useCallback(
    ({ target: { value } }: React.ChangeEvent<HTMLInputElement>) => {
      setValue(value);

      const trimmedValue = value.trim();
      const newQuickActions = [];

      if (trimmedValue.length > 0) {
        const couldBeURL =
          trimmedValue.startsWith('https://') && !trimmedValue.includes(' ');

        if (couldBeURL) {
          newQuickActions.push({
            key: 'open-url',
            label: (
              <FormattedMessage
                id='search.quick_action.open_url'
                defaultMessage='Open URL in Mastodon'
              />
            ),
            action: async () => {
              const result = await dispatch(openURL({ url: trimmedValue }));

              if (isFulfilled(result)) {
                if (result.payload.accounts[0]) {
                  history.push(`/@${result.payload.accounts[0].acct}`);
                } else if (result.payload.statuses[0]) {
                  history.push(
                    `/@${result.payload.statuses[0].account.acct}/${result.payload.statuses[0].id}`,
                  );
                }
              }

              unfocus();
            },
          });
        }

        const couldBeHashtag =
          (trimmedValue.startsWith('#') && trimmedValue.length > 1) ||
          trimmedValue.match(HASHTAG_REGEX);

        if (couldBeHashtag) {
          newQuickActions.push({
            key: 'go-to-hashtag',
            label: (
              <FormattedMessage
                id='search.quick_action.go_to_hashtag'
                defaultMessage='Go to hashtag {x}'
                values={{ x: <mark>#{trimmedValue.replace(/^#/, '')}</mark> }}
              />
            ),
            action: () => {
              const query = trimmedValue.replace(/^#/, '');
              history.push(`/tags/${query}`);
              void dispatch(clickSearchResult({ q: query, type: 'hashtag' }));
              unfocus();
            },
          });
        }

        const couldBeUsername = /^@?[a-z0-9_-]+(@[^\s]+)?$/i.exec(trimmedValue);

        if (couldBeUsername) {
          newQuickActions.push({
            key: 'go-to-account',
            label: (
              <FormattedMessage
                id='search.quick_action.go_to_account'
                defaultMessage='Go to profile {x}'
                values={{ x: <mark>@{trimmedValue.replace(/^@/, '')}</mark> }}
              />
            ),
            action: () => {
              const query = trimmedValue.replace(/^@/, '');
              history.push(`/@${query}`);
              void dispatch(clickSearchResult({ q: query, type: 'account' }));
              unfocus();
            },
          });
        }

        const couldBeStatusSearch = searchEnabled;

        if (couldBeStatusSearch && signedIn) {
          newQuickActions.push({
            key: 'status-search',
            label: (
              <FormattedMessage
                id='search.quick_action.status_search'
                defaultMessage='Posts matching {x}'
                values={{ x: <mark>{trimmedValue}</mark> }}
              />
            ),
            action: () => {
              submit(trimmedValue, 'statuses');
            },
          });
        }

        newQuickActions.push({
          key: 'account-search',
          label: (
            <FormattedMessage
              id='search.quick_action.account_search'
              defaultMessage='Profiles matching {x}'
              values={{ x: <mark>{trimmedValue}</mark> }}
            />
          ),
          action: () => {
            submit(trimmedValue, 'accounts');
          },
        });
      }

      setQuickActions(newQuickActions);
    },
    [dispatch, history, signedIn, setValue, setQuickActions, submit],
  );

  const handleClear = useCallback(() => {
    setValue('');
    setQuickActions([]);
    setSelectedOption(-1);
  }, [setValue, setQuickActions, setSelectedOption]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case 'Escape':
          e.preventDefault();
          unfocus();

          break;
        case 'ArrowDown':
          e.preventDefault();

          if (navigableOptions.length > 0) {
            setSelectedOption(
              Math.min(selectedOption + 1, navigableOptions.length - 1),
            );
          }

          break;
        case 'ArrowUp':
          e.preventDefault();

          if (navigableOptions.length > 0) {
            setSelectedOption(Math.max(selectedOption - 1, -1));
          }

          break;
        case 'Enter':
          e.preventDefault();

          if (selectedOption === -1) {
            submit(value);
          } else if (navigableOptions.length > 0) {
            navigableOptions[selectedOption]?.action(e);
          }

          break;
        case 'Delete':
          if (selectedOption > -1 && navigableOptions.length > 0) {
            const search = navigableOptions[selectedOption];

            if (typeof search?.forget === 'function') {
              e.preventDefault();
              search.forget(e);
            }
          }

          break;
      }
    },
    [navigableOptions, value, selectedOption, setSelectedOption, submit],
  );

  const handleFocus = useCallback(() => {
    setExpanded(true);
    setSelectedOption(-1);

    if (searchInputRef.current && !singleColumn) {
      const { left, right } = searchInputRef.current.getBoundingClientRect();

      if (
        left < 0 ||
        right > (window.innerWidth || document.documentElement.clientWidth)
      ) {
        searchInputRef.current.scrollIntoView();
      }
    }
  }, [setExpanded, setSelectedOption, singleColumn]);

  const handleBlur = useCallback(() => {
    setExpanded(false);
    setSelectedOption(-1);
  }, [setExpanded, setSelectedOption]);

  return (
    <form className={classNames('search', { active: expanded })}>
      <input
        ref={searchInputRef}
        className='search__input'
        type='text'
        placeholder={intl.formatMessage(
          signedIn ? messages.placeholderSignedIn : messages.placeholder,
        )}
        aria-label={intl.formatMessage(
          signedIn ? messages.placeholderSignedIn : messages.placeholder,
        )}
        value={value}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        onFocus={handleFocus}
        onBlur={handleBlur}
      />

      <button type='button' className='search__icon' onClick={handleClear}>
        <Icon
          id='search'
          icon={SearchIcon}
          className={hasValue ? '' : 'active'}
        />
        <Icon
          id='times-circle'
          icon={CancelIcon}
          className={hasValue ? 'active' : ''}
          aria-label={intl.formatMessage(messages.placeholder)}
        />
      </button>

      <div className='search__popout'>
        {!hasValue && (
          <>
            <h4>
              <FormattedMessage
                id='search_popout.recent'
                defaultMessage='Recent searches'
              />
            </h4>

            <div className='search__popout__menu'>
              {recentOptions.length > 0 ? (
                recentOptions.map(({ label, key, action, forget }, i) => (
                  <button
                    key={key}
                    onMouseDown={action}
                    className={classNames(
                      'search__popout__menu__item search__popout__menu__item--flex',
                      { selected: selectedOption === i },
                    )}
                  >
                    <span>{label}</span>
                    <button className='icon-button' onMouseDown={forget}>
                      <Icon id='times' icon={CloseIcon} />
                    </button>
                  </button>
                ))
              ) : (
                <div className='search__popout__menu__message'>
                  <FormattedMessage
                    id='search.no_recent_searches'
                    defaultMessage='No recent searches'
                  />
                </div>
              )}
            </div>
          </>
        )}

        {quickActions.length > 0 && (
          <>
            <h4>
              <FormattedMessage
                id='search_popout.quick_actions'
                defaultMessage='Quick actions'
              />
            </h4>

            <div className='search__popout__menu'>
              {quickActions.map(({ key, label, action }, i) => (
                <button
                  key={key}
                  onMouseDown={action}
                  className={classNames('search__popout__menu__item', {
                    selected: selectedOption === i,
                  })}
                >
                  {label}
                </button>
              ))}
            </div>
          </>
        )}

        <h4>
          <FormattedMessage
            id='search_popout.options'
            defaultMessage='Search options'
          />
        </h4>

        {searchEnabled && signedIn ? (
          <div className='search__popout__menu'>
            {searchOptions.map(({ key, label, action }, i) => (
              <button
                key={key}
                onMouseDown={action}
                className={classNames('search__popout__menu__item', {
                  selected:
                    selectedOption ===
                    (quickActions.length || recent.length) + i,
                })}
              >
                {label}
              </button>
            ))}
          </div>
        ) : (
          <div className='search__popout__menu__message'>
            {searchEnabled ? (
              <FormattedMessage
                id='search_popout.full_text_search_logged_out_message'
                defaultMessage='Only available when logged in.'
              />
            ) : (
              <FormattedMessage
                id='search_popout.full_text_search_disabled_message'
                defaultMessage='Not available on {domain}.'
                values={{ domain }}
              />
            )}
          </div>
        )}
      </div>
    </form>
  );
};
