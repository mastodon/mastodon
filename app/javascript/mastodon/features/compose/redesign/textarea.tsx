import type React from 'react';
import type { RefCallback } from 'react';
import { useCallback, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { TextareaAutosizeProps } from 'react-textarea-autosize';

import {
  changeCompose,
  fetchComposeSuggestions,
  clearComposeSuggestions,
  selectComposeSuggestion,
} from '@/mastodon/actions/compose';
import { processPasteOrDrop } from '@/mastodon/actions/compose_typed';
import { textAtCursorMatchesToken } from '@/mastodon/components/autosuggest/utils';
import { Avatar } from '@/mastodon/components/avatar';
import { DisplayName } from '@/mastodon/components/display_name';
import { Emoji } from '@/mastodon/components/emoji';
import { TextArea } from '@/mastodon/components/form_fields';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import {
  getAllMenuItems,
  Menu,
  MenuItem,
  useMenuContext,
} from '@/mastodon/components/menu';
import { PopoverMenuCard } from '@/mastodon/components/menu/card';
import { useMergedRefs } from '@/mastodon/hooks/useMergedRefs';
import { usePrevious } from '@/mastodon/hooks/usePrevious';
import {
  COMPOSER_TEXTAREA_ID,
  focusComposerTextarea,
} from '@/mastodon/reducers/slices/composer';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import type { Suggestion } from './selectors';
import {
  selectComposeType,
  selectSuggestions,
  stringOrUndefined,
} from './selectors';
import classes from './styles.module.scss';

const messages = defineMessages({
  placeholder: {
    id: 'compose.post.placeholder',
    defaultMessage: 'What would you like to say?',
  },
  messagePlaceholder: {
    id: 'compose.message.placeholder',
    defaultMessage: 'Add your recipients and your message.',
    description:
      'Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.',
  },
});

type ComposeTextareaProps = Omit<
  TextareaAutosizeProps,
  | 'placeholder'
  | 'onFocus'
  | 'onBlur'
  | 'onPaste'
  | 'onDrop'
  | 'onChange'
  | 'onKeyDown'
> & { onSubmit: () => void };

const selectComposeTextState = createAppSelector(
  [(state) => state.compose],
  (compose) => ({
    text: compose.get('text') as string,
    lang: compose.get('language') as string,
    isSubmitting: !!compose.get('is_submitting'),
  }),
);

export const ComposeTextarea: React.FC<ComposeTextareaProps> = ({
  onSubmit,
  className,
  disabled,
  ...props
}) => {
  const intl = useIntl();

  const type = useAppSelector(selectComposeType);
  const { text, lang, isSubmitting } = useAppSelector(selectComposeTextState);

  const dispatch = useAppDispatch();
  const onClickWrapper: React.MouseEventHandler<HTMLDivElement> = useCallback(
    (event) => {
      if (event.target instanceof HTMLDivElement) {
        event.target.querySelector('textarea')?.focus();
      }
    },
    [],
  );

  // Suggestion logic
  const suggestions = useAppSelector(selectSuggestions);
  const lastTokenRef = useRef<string | null>(null);
  const tokenStartRef = useRef(0);
  const onSuggestionClick: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(
      (event) => {
        const { id, index, type } = event.currentTarget.dataset;
        const suggestion = suggestions.find((suggestion, i) =>
          suggestion.type === type && suggestion.id
            ? suggestion.id === id
            : index && Number.parseInt(index) === i,
        );
        if (!suggestion) {
          return;
        }

        dispatch(
          selectComposeSuggestion(
            tokenStartRef.current,
            lastTokenRef.current,
            suggestion,
            ['text'],
          ),
        );
        focusComposerTextarea(true);
      },
      [dispatch, suggestions],
    );
  const [textArea, setTextArea] = useState<HTMLTextAreaElement | null>(null);
  const [suggestionList, setSuggestionList] = useState<HTMLDivElement | null>(
    null,
  );

  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));

      const [tokenStart, token] = textAtCursorMatchesToken(
        event.target.value,
        event.target.selectionStart,
        ['@', '＠', ':', '#', '＃'],
      );

      if (token !== null && lastTokenRef.current !== token) {
        tokenStartRef.current = tokenStart;
        lastTokenRef.current = token;
        dispatch(fetchComposeSuggestions(token));
      } else if (token === null) {
        lastTokenRef.current = null;
        dispatch(clearComposeSuggestions());
      }
    },
    [dispatch, lastTokenRef],
  );

  const onKeyDown: React.KeyboardEventHandler<HTMLTextAreaElement> =
    useCallback(
      (event) => {
        const key = normalizeKey(event.key);
        if (key === 'enter' && (event.ctrlKey || event.metaKey)) {
          onSubmit();
          event.preventDefault();
        } else if (key === 'escape') {
          event.currentTarget.blur();
        } else if (key === 'down' && suggestions.length > 0 && suggestionList) {
          (getAllMenuItems(suggestionList).at(0) ?? suggestionList).focus();
        }
      },
      [onSubmit, suggestionList, suggestions.length],
    );

  const onPasteOrDrop = useCallback(
    (event: React.ClipboardEvent | React.DragEvent) => {
      const data =
        'clipboardData' in event ? event.clipboardData : event.dataTransfer;
      if (data.files.length === 1) {
        event.preventDefault();
      }
      dispatch(processPasteOrDrop(data));
    },
    [dispatch],
  );

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions -- This just moves focus to the textarea.
    <div
      onClick={onClickWrapper}
      className={classNames(className, classes.textareaWrapper)}
    >
      <TextArea
        {...props}
        id={COMPOSER_TEXTAREA_ID}
        ref={setTextArea}
        value={text}
        lang={lang}
        placeholder={intl.formatMessage(
          type === 'message'
            ? messages.messagePlaceholder
            : messages.placeholder,
        )}
        disabled={disabled || isSubmitting}
        onKeyDown={onKeyDown}
        onDrop={onPasteOrDrop}
        onPaste={onPasteOrDrop}
        onChange={onChange}
      />

      {suggestions.length > 0 && (
        <Menu noFocus>
          <AutosuggestMenuList textElement={textArea} ref={setSuggestionList}>
            {suggestions.map((suggestion, index) => (
              <MenuItem
                key={`${suggestion.type}:${suggestion.id}`}
                onClick={onSuggestionClick}
                data-index={index}
                data-type={suggestion.type}
                data-id={suggestion.id}
              >
                <AutosuggestItem suggestion={suggestion} />
              </MenuItem>
            ))}
          </AutosuggestMenuList>
        </Menu>
      )}
    </div>
  );
};

const AutosuggestMenuList: React.FC<{
  children: React.ReactElement[];
  textElement: HTMLTextAreaElement | null;
  ref: RefCallback<HTMLDivElement>;
}> = ({ children, textElement, ref }) => {
  const suggestions = useAppSelector(selectSuggestions);
  const token = useAppSelector((state) =>
    stringOrUndefined(state.compose.get('suggestion_token')),
  );
  const lastToken = usePrevious(token);

  const { popover, menuListProps } = useMenuContext();

  if (!popover.isMenuOpen && token !== lastToken && suggestions.length > 0) {
    popover.openMenu();
  }

  const mergedRef = useMergedRefs(menuListProps.ref, ref);

  return (
    <PopoverMenuCard
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={textElement}
      popoverElement={popover.popover}
      container={null}
      placement='bottom-start'
      {...menuListProps}
      ref={mergedRef}
    >
      {children}
    </PopoverMenuCard>
  );
};

const AutosuggestItem: React.FC<{ suggestion: Suggestion }> = ({
  suggestion,
}) => {
  if (suggestion.type === 'account') {
    return <AutosuggestAccount id={suggestion.id} />;
  } else if (suggestion.type === 'hashtag') {
    return <div>#{suggestion.name}</div>;
  } else {
    const colons = `:${suggestion.id}:`;
    return (
      <div>
        <Emoji code={suggestion.native ?? colons} />

        {colons}
      </div>
    );
  }
};

const AutosuggestAccount: React.FC<{ id: string }> = ({ id }) => {
  const account = useAppSelector((state) => selectPlainAccount(state, id));

  if (!account) {
    return null;
  }

  return (
    <div>
      <Avatar account={account} />
      <DisplayName account={account} />
    </div>
  );
};
