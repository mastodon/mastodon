import { useCallback, useState, useRef, useMemo, useId } from 'react';

import {
  defineMessages,
  useIntl,
  FormattedMessage,
  FormattedList,
} from 'react-intl';

import { useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import { Combobox } from '@/mastodon/components/form_fields';
import {
  ComboboxMenuGroupTitle,
  ComboboxMenuItem,
} from '@/mastodon/components/form_fields/combobox_field';
import {
  FOCUS_TARGET,
  useFocusAfterNavigation,
} from '@/mastodon/components/navigation_focus_target';
import { getCollectionPath } from '@/mastodon/features/collections/utils';
import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import {
  clickSearchResult,
  forgetSearchResult,
  openURL,
} from 'mastodon/actions/search';
import { useIdentity } from 'mastodon/identity_context';
import { domain, searchEnabled } from 'mastodon/initial_state';
import type { RecentSearch, SearchType } from 'mastodon/models/search';
import { useAppSelector, useAppDispatch } from 'mastodon/store';
import { HASHTAG_REGEX } from 'mastodon/utils/hashtags';

import classes from './search.module.scss';

const messages = defineMessages({
  searchLabel: { id: 'search.placeholder', defaultMessage: 'Search' },
  searchLabelSignedIn: {
    id: 'search.search_or_paste',
    defaultMessage: 'Search or paste URL',
  },
  clearSearch: { id: 'search.clear', defaultMessage: 'Clear search' },
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

interface SearchOption {
  id: string;
  label: React.ReactNode;
  action: () => void;
  forget?: (e: React.MouseEvent | React.KeyboardEvent) => void;
}

const renderGroupTitle = (groupKey: string, titleId: string) => {
  const titleMap = {
    recentOptions: (
      <FormattedMessage
        id='search_popout.recent'
        defaultMessage='Recent searches'
      />
    ),
    quickActions: (
      <FormattedMessage
        id='search_popout.quick_actions'
        defaultMessage='Quick actions'
      />
    ),
    searchOptions: (
      <FormattedMessage
        id='search_popout.options'
        defaultMessage='Search options'
      />
    ),
  } as const;

  return (
    <ComboboxMenuGroupTitle id={titleId}>
      {titleMap[groupKey as keyof typeof titleMap]}
    </ComboboxMenuGroupTitle>
  );
};

const rendeSuggestion = (item: SearchOption) => {
  return <ComboboxMenuItem>{item.label}</ComboboxMenuItem>;
};

export const Search: React.FC<{
  initialValue?: string;
}> = ({ initialValue }) => {
  const intl = useIntl();
  const recent = useAppSelector((state) => state.search.recent);
  const { signedIn } = useIdentity();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const searchInputRef = useRef<HTMLInputElement>(null);
  const [value, setValue] = useState(initialValue ?? '');
  const hasValue = value.length > 0;
  const [quickActions, setQuickActions] = useState<SearchOption[]>([]);

  const [shouldOpenOnFocus, setShouldOpenOnFocus] = useState(false);
  const focusAfterNavigation = useFocusAfterNavigation(
    FOCUS_TARGET.SEARCH,
    () => {
      setShouldOpenOnFocus(true);
    },
  );

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
          id: 'prompt-has',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>has:</strong>{' '}
              <FormattedList
                type='disjunction'
                value={['media', 'poll', 'embed']}
              />
            </span>
          ),
          action: () => {
            insertText('has:');
          },
        },
        {
          id: 'prompt-is',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>is:</strong>{' '}
              <FormattedList
                type='disjunction'
                value={['reply', 'sensitive']}
              />
            </span>
          ),
          action: () => {
            insertText('is:');
          },
        },
        {
          id: 'prompt-language',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>language:</strong>{' '}
              <FormattedMessage
                id='search_popout.language_code'
                defaultMessage='ISO language code'
              />
            </span>
          ),
          action: () => {
            insertText('language:');
          },
        },
        {
          id: 'prompt-from',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>from:</strong>{' '}
              <FormattedMessage id='search_popout.user' defaultMessage='user' />
            </span>
          ),
          action: () => {
            insertText('from:');
          },
        },
        {
          id: 'prompt-before',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>before:</strong>{' '}
              <FormattedMessage
                id='search_popout.specific_date'
                defaultMessage='specific date'
              />
            </span>
          ),
          action: () => {
            insertText('before:');
          },
        },
        {
          id: 'prompt-during',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>during:</strong>{' '}
              <FormattedMessage
                id='search_popout.specific_date'
                defaultMessage='specific date'
              />
            </span>
          ),
          action: () => {
            insertText('during:');
          },
        },
        {
          id: 'prompt-after',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>after:</strong>{' '}
              <FormattedMessage
                id='search_popout.specific_date'
                defaultMessage='specific date'
              />
            </span>
          ),
          action: () => {
            insertText('after:');
          },
        },
        {
          id: 'prompt-in',
          label: (
            <span className={classes.searchSuggestion}>
              <strong>in:</strong>{' '}
              <FormattedList
                type='disjunction'
                value={['all', 'library', 'public']}
              />
            </span>
          ),
          action: () => {
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
        id: `${search.type}/${search.q}`,
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
        },
        forget: (e) => {
          e.stopPropagation();
          void dispatch(forgetSearchResult(search));
        },
      })),
    [dispatch, history, recent],
  );

  const groupedSuggestions = useMemo(
    () =>
      hasValue
        ? ({
            quickActions,
            searchOptions,
          } as const)
        : ({
            recentOptions,
            quickActions,
            searchOptions,
          } as const),
    [hasValue, quickActions, recentOptions, searchOptions],
  );

  const submit = useCallback(
    (q: string, type?: SearchType) => {
      void dispatch(clickSearchResult({ q, type }));
      const queryParams = new URLSearchParams({ q });
      if (type) queryParams.set('type', type);
      history.push({ pathname: '/search', search: queryParams.toString() });
    },
    [dispatch, history],
  );

  const handleFormSubmit = useCallback(() => {
    submit(value);
  }, [submit, value]);

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
            id: 'open-url',
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
                } else if (result.payload.collections[0]) {
                  history.push(
                    getCollectionPath(result.payload.collections[0].id),
                  );
                }
              }
            },
          });
        }

        const couldBeHashtag =
          (trimmedValue.startsWith('#') && trimmedValue.length > 1) ||
          trimmedValue.match(HASHTAG_REGEX);

        if (couldBeHashtag) {
          newQuickActions.push({
            id: 'go-to-hashtag',
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
            },
          });
        }

        const couldBeUsername = /^@?[a-z0-9_-]+(@[^\s]+)?$/i.exec(trimmedValue);

        if (couldBeUsername) {
          newQuickActions.push({
            id: 'go-to-account',
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
            },
          });
        }

        const couldBeStatusSearch = searchEnabled;

        if (couldBeStatusSearch && signedIn) {
          newQuickActions.push({
            id: 'status-search',
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
          id: 'account-search',
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
    [signedIn, dispatch, history, submit],
  );

  const handleSelectItem = useCallback((item: SearchOption) => {
    item.action();
  }, []);

  const getGroupEmptyMessage = useCallback(
    (groupKey: keyof typeof groupedSuggestions) => {
      if (groupKey === 'searchOptions') {
        return searchEnabled ? (
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
        );
      }
      if (groupKey === 'recentOptions') {
        return (
          <FormattedMessage
            id='search.no_recent_searches'
            defaultMessage='No recent searches'
          />
        );
      }

      return null;
    },
    [],
  );

  const formRef = useRef<HTMLFormElement>(null);
  const inputId = useId();

  return (
    <form ref={formRef} className='search' onSubmit={handleFormSubmit}>
      <label htmlFor={inputId} className='sr-only'>
        {intl.formatMessage(
          signedIn ? messages.searchLabelSignedIn : messages.searchLabel,
        )}
      </label>
      <Combobox
        id={inputId}
        value={value}
        ref={useMergedRefs(searchInputRef, focusAfterNavigation)}
        onChange={handleChange}
        inputMode='search'
        // isLoading={isLoadingSuggestions}
        items={groupedSuggestions}
        // getIsItemDisabled={getIsItemDisabled}
        getGroupEmptyMessage={getGroupEmptyMessage}
        renderItem={rendeSuggestion}
        renderGroupTitle={renderGroupTitle}
        onSelectItem={handleSelectItem}
        autoHighlightFirstItem={false}
        openOnFocus={shouldOpenOnFocus}
      />
    </form>
  );
};
