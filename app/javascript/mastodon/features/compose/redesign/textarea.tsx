import type React from 'react';
import type { RefCallback } from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import { useThrottledCallback } from 'use-debounce';

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
import { LocalCustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { TextArea } from '@/mastodon/components/form_fields';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import {
  getAllMenuItems,
  Menu,
  MenuItem,
  useMenuContext,
} from '@/mastodon/components/menu';
import { MenuCard } from '@/mastodon/components/menu/card';
import { Popover } from '@/mastodon/components/popover';
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
  React.ComponentPropsWithoutRef<'textarea'>,
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

  // Selectors
  const type = useAppSelector(selectComposeType);
  const { text, lang, isSubmitting } = useAppSelector(selectComposeTextState);
  const suggestions = useAppSelector(selectSuggestions);
  const dispatch = useAppDispatch();

  // Suggestion state and refs
  const [textArea, setTextArea] = useState<HTMLTextAreaElement | null>(null); // The textarea itself.
  const [suggestionList, setSuggestionList] = useState<HTMLDivElement | null>( // Suggestion list element.
    null,
  );
  const [mirrorElement, setMirrorElement] = useState<HTMLElement | null>(null); // Reference to the mirror element.
  const [selectedText, setSelectedText] = useState(text); // The actual selected text inside the mirror.
  const lastTokenRef = useRef<string | null>(null); // The last suggestion token encountered.
  const tokenStartRef = useRef(0); // Character location of the token start.
  const updatePopoverRef = useRef<(() => void) | null>(null); // Reference to the popover update callback.

  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      // Update the composer text.
      dispatch(changeCompose(event.target.value));

      // Detect a token, and if so fetch suggestions, or dismiss them if not.
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
          dispatch(clearComposeSuggestions());
        } else if (key === 'escape') {
          // Dismiss the suggestions if we're displaying any.
          if (suggestions.length > 0) {
            dispatch(clearComposeSuggestions());
          } else {
            // Otherwise lose focus on the textarea.
            event.currentTarget.blur();
          }
        } else if (key === 'down' && suggestions.length > 0 && suggestionList) {
          // If we have suggestions, the down arrow selects the first one.
          (getAllMenuItems(suggestionList).at(0) ?? suggestionList).focus();
        }
      },
      [dispatch, onSubmit, suggestionList, suggestions.length],
    );

  // When the caret or selection changes, update the selected text and clear the composer if it doesn't include a token.
  const onSelect: React.ReactEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      if (lastTokenRef.current === null) {
        return;
      }

      const { selectionStart, value } = event.currentTarget;
      const tokenEnd = tokenStartRef.current + lastTokenRef.current.length;
      setSelectedText(value.slice(0, tokenEnd)); // Only set the text up to the selected end point.

      if (selectionStart < tokenStartRef.current || selectionStart > tokenEnd) {
        lastTokenRef.current = null;
        dispatch(clearComposeSuggestions());
      }
    },
    [dispatch],
  );

  // Debounced callback to update the popover on scroll.
  const onTextAreaScroll = useThrottledCallback(() => {
    // Call the popover update callback. This enables the popover to adjust position with scroll.
    updatePopoverRef.current?.();

    if (textArea && mirrorElement) {
      // Set top to scroll offset so bottom edge looks right.
      mirrorElement.style.setProperty('top', `${-1 * textArea.scrollTop}px`);

      const { height } = textArea.getBoundingClientRect();
      const offset = mirrorElement.offsetHeight - textArea.scrollTop;
      if (offset < 0 || offset > height) {
        dispatch(clearComposeSuggestions());
      }
    }
  }, 0);

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

  return (
    <div className={classes.textareaWrapper}>
      <TextArea
        {...props}
        dir='auto'
        aria-autocomplete='list'
        id={COMPOSER_TEXTAREA_ID}
        className={classNames(className, classes.textarea)}
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
        onSelect={onSelect}
        onScroll={onTextAreaScroll}
        aria-controls={suggestionList?.id}
      />

      <div className={classes.textareaMirror} ref={setMirrorElement}>
        {selectedText}
      </div>

      <Menu noFocus>
        {suggestions.length > 0 && (
          <AutosuggestMenuList
            listRef={setSuggestionList}
            mirrorElement={mirrorElement}
            updateRef={updatePopoverRef}
          >
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
        )}
      </Menu>
    </div>
  );
};

const AutosuggestMenuList: React.FC<{
  children: React.ReactElement[];
  listRef: RefCallback<HTMLDivElement>;
  mirrorElement: HTMLElement | null;
  updateRef: React.RefObject<(() => void) | null>;
}> = ({ children, listRef, mirrorElement, updateRef }) => {
  const suggestions = useAppSelector(selectSuggestions);
  const token = useAppSelector((state) =>
    stringOrUndefined(state.compose.get('suggestion_token')),
  );
  const lastToken = usePrevious(token);

  const { popover, menuListProps } = useMenuContext();

  if (!popover.isMenuOpen && token !== lastToken && suggestions.length > 0) {
    popover.openMenu();
  }

  useEffect(() => {
    const update = updateRef;
    return () => {
      update.current = null;
    };
  }, [updateRef]);

  const mergedRef = useMergedRefs(menuListProps.ref, listRef);

  return (
    <Popover
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={mirrorElement}
      popoverElement={popover.popover}
      container={null}
      placement='bottom-start'
    >
      {({ props: popoverChildProps, update }) => {
        updateRef.current = update;
        return (
          <MenuCard {...popoverChildProps} {...menuListProps} ref={mergedRef}>
            <LocalCustomEmojiProvider>{children}</LocalCustomEmojiProvider>
          </MenuCard>
        );
      }}
    </Popover>
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
