import type React from 'react';
import type { RefCallback } from 'react';
import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type { VirtualElement } from '@floating-ui/react-dom';

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

const MIRROR_ID = `${COMPOSER_TEXTAREA_ID}-mirror`;

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

  // Suggestion logic
  const [textArea, setTextArea] = useState<HTMLTextAreaElement | null>(null);
  const [suggestionList, setSuggestionList] = useState<HTMLDivElement | null>(
    null,
  );
  const suggestions = useAppSelector(selectSuggestions);
  const lastTokenRef = useRef<string | null>(null);
  const tokenStartRef = useRef(0);

  useEffect(() => {
    return () => {
      dispatch(clearComposeSuggestions());
    };
  }, [dispatch]);

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
          (getAllMenuItems(suggestionList).at(0) ?? suggestionList).focus();
        }
      },
      [dispatch, onSubmit, suggestionList, suggestions.length],
    );

  // When showing suggestions, dismiss them if the selection changes.
  const onSelect: React.ReactEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      if (lastTokenRef.current === null) {
        return;
      }

      const { selectionStart } = event.currentTarget;
      const tokenEnd = tokenStartRef.current + lastTokenRef.current.length;

      if (selectionStart < tokenStartRef.current || selectionStart > tokenEnd) {
        lastTokenRef.current = null;
        dispatch(clearComposeSuggestions());
      }
    },
    [dispatch],
  );

  useEffect(() => {
    if (!textArea) {
      return;
    }

    const rect = textArea.getBoundingClientRect();
    const div = document.createElement('div');
    const styles = getComputedStyle(textArea);
    div.style.width = `${rect.width}px`;
    div.style.whiteSpace = 'pre-wrap';
    div.style.padding = styles.padding;
    div.style.maxHeight = `${rect.height}px`;
    div.style.border = styles.border;
    div.ariaHidden = 'true';
    div.style.visibility = 'hidden';

    div.id = MIRROR_ID;

    document.body.appendChild(div);

    return () => {
      document.body.removeChild(div);
    };
  }, [textArea]);

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
    <>
      <TextArea
        {...props}
        dir='auto'
        aria-autocomplete='list'
        id={COMPOSER_TEXTAREA_ID}
        className={classNames(className, classes.textareaWrapper)}
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
        aria-controls={suggestionList?.id}
      />

      <Menu noFocus>
        {suggestions.length > 0 && (
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
        )}
      </Menu>
    </>
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

  if (!textElement) {
    return null;
  }

  const virtualEle = {
    getBoundingClientRect() {
      const rect = textElement.getBoundingClientRect();
      let height = rect.height;

      const div = document.getElementById(MIRROR_ID);
      if (div) {
        div.textContent = textElement.value.slice(0, textElement.selectionEnd);
        const relativeHeight = div.offsetHeight - textElement.scrollTop;
        height = Math.min(Math.max(relativeHeight + 4, 0), rect.height);
      }

      return {
        x: rect.x,
        y: rect.y,
        top: rect.top,
        bottom: rect.bottom,
        left: rect.left,
        right: rect.right,
        height: height,
        width: rect.width,
      };
    },
    contextElement: textElement,
  } satisfies VirtualElement;

  return (
    <PopoverMenuCard
      isOpen={popover.isMenuOpen}
      onClose={popover.closeMenu}
      reference={virtualEle}
      popoverElement={popover.popover}
      offset={4}
      container={null}
      placement='bottom-start'
      {...menuListProps}
      ref={mergedRef}
    >
      <LocalCustomEmojiProvider>{children}</LocalCustomEmojiProvider>
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
