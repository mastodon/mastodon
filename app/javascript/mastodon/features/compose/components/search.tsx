import {
  useCallback,
  useState,
  useRef,
  useEffect,
  useMemo,
  useId,
} from 'react';

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
  clearSearch: { id: 'search.clear', defaultMessage: 'Clear search' },
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

const ClearButton: React.FC<{
  onClick: () => void;
  hasValue: boolean;
}> = ({ onClick, hasValue }) => {
  const intl = useIntl();

  return (
    <div
      className={classNames('search__icon-wrapper', { 'has-value': hasValue })}
    >
      <Icon id='search' icon={SearchIcon} className='search__icon' />
      <button
        type='button'
        onClick={onClick}
        className='search__icon search__icon--clear-button'
        tabIndex={hasValue ? undefined : -1}
        aria-hidden={!hasValue}
      >
        <Icon
          id='times-circle'
          icon={CancelIcon}
          aria-label={intl.formatMessage(messages.clearSearch)}
        />
      </button>
    </div>
  );
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

  const unfocus = useCallback(() => {
    document.querySelector('.ui')?.parentElement?.focus();
    setExpanded(false);
  }, []);

  const insertText = useCallback((text: string) => {
    setValue((currentValue) => {
      if (currentValue === '') {
        return text;
      } else if (currentValue.endsWith(' ')) {
        return `${currentValue}${text}`;
      } else {
        return `${currentValue} ${text}`;
      }
    });
  }, []);

  const searchOptions = useMemo(() => {
    if (!searchEnabled) {
      return [];
    } else {
      const options: SearchOption[] = [
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
              <FormattedList
                type='disjunction'
                value={['reply', 'sensitive']}
              />
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
      ];
      return options;
    }
  }, [insertText]);

  const recentOptions: SearchOption[] = useMemo(
    () =>
      recent.map((search) => ({
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
            history.push({
              pathname: '/search',
              search: queryParams.toString(),
            });
          }

          unfocus();
        },
        forget: (e) => {
          e.stopPropagation();
          void dispatch(forgetSearchResult(search));
        },
      })),
    [dispatch, history, recent, unfocus],
  );

  const navigableOptions: SearchOption[] = useMemo(
    () =>
      hasValue
        ? quickActions.concat(searchOptions)
        : recentOptions.concat(quickActions, searchOptions),
    [hasValue, quickActions, recentOptions, searchOptions],
  );

  const submit = useCallback(
    (q: string, type?: SearchType) => {
      void dispatch(clickSearchResult({ q, type }));
      const queryParams = new URLSearchParams({ q });
      if (type) queryParams.set('type', type);
      history.push({ pathname: '/search', search: queryParams.toString() });
      unfocus();
    },
    [dispatch, history, unfocus],
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
    [signedIn, dispatch, unfocus, history, submit],
  );

  const handleClear = useCallback(() => {
    setValue('');
    setQuickActions([]);
    setSelectedOption(-1);
    unfocus();
  }, [unfocus]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case 'Escape':
          e.preventDefault();
          searchInputRef.current?.focus();
          setExpanded(false);

          break;
        case 'ArrowDown':
          e.preventDefault();

          if (!expanded) {
            setExpanded(true);
          }

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
    [expanded, navigableOptions, selectedOption, submit, value],
  );

  const handleInputFocus = useCallback(() => {
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

  const handleInputBlur = useCallback(() => {
    setSelectedOption(-1);
  }, [setSelectedOption]);

  const getOptionFocusHandler = useCallback((index: number) => {
    return () => {
      setSelectedOption(index);
    };
  }, []);

  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    // If the search popover is expanded, close it when tabbing or
    // clicking outside of it or the search form, while allowing
    // tabbing or clicking inside of the popover
    if (expanded) {
      function closeOnLeave(event: FocusEvent | MouseEvent) {
        const form = formRef.current;
        const isClickInsideForm =
          form &&
          (form === event.target || form.contains(event.target as Node));
        if (!isClickInsideForm) {
          setExpanded(false);
        }
      }
      document.addEventListener('focusin', closeOnLeave);
      document.addEventListener('click', closeOnLeave);

      return () => {
        document.removeEventListener('focusin', closeOnLeave);
        document.removeEventListener('click', closeOnLeave);
      };
    }
    return () => null;
  }, [expanded]);

  const searchOptionsHeading = useId();

  return (
    <form ref={formRef} className={classNames('search', { active: expanded })}>
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
        onFocus={handleInputFocus}
        onBlur={handleInputBlur}
      />

      <ClearButton hasValue={hasValue} onClick={handleClear} />

      {/* eslint-disable-next-line jsx-a11y/no-noninteractive-element-interactions */}
      <div
        className='search__popout'
        role='dialog'
        tabIndex={-1}
        aria-labelledby={searchOptionsHeading}
        onKeyDown={handleKeyDown}
      >
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
                  <div
                    key={key}
                    tabIndex={0}
                    role='button'
                    onMouseDown={action}
                    onFocus={getOptionFocusHandler(i)}
                    className={classNames(
                      'search__popout__menu__item search__popout__menu__item--flex',
                      { selected: selectedOption === i },
                    )}
                  >
                    <span>{label}</span>
                    <button
                      className='icon-button'
                      onMouseDown={forget}
                      type='button'
                    >
                      <Icon id='times' icon={CloseIcon} />
                    </button>
                  </div>
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
                  onFocus={getOptionFocusHandler(i)}
                  className={classNames('search__popout__menu__item', {
                    selected: selectedOption === i,
                  })}
                  type='button'
                >
                  {label}
                </button>
              ))}
            </div>
          </>
        )}

        <h4 id={searchOptionsHeading}>
          <FormattedMessage
            id='search_popout.options'
            defaultMessage='Search options'
          />
        </h4>

        {searchEnabled && signedIn ? (
          <div className='search__popout__menu'>
            {searchOptions.map(({ key, label, action }, i) => {
              const currentIndex = (quickActions.length || recent.length) + i;
              return (
                <button
                  key={key}
                  onMouseDown={action}
                  onFocus={getOptionFocusHandler(currentIndex)}
                  className={classNames('search__popout__menu__item', {
                    selected: selectedOption === currentIndex,
                  })}
                  type='button'
                >
                  {label}
                </button>
              );
            })}
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
