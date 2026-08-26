import { useCallback, useState } from 'react';

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
import type { OnSuggestionSelect } from '@/mastodon/components/autosuggest/hooks';
import { useAutosuggestMenu } from '@/mastodon/components/autosuggest/hooks';
import { AutosuggestMenu } from '@/mastodon/components/autosuggest/list';
import { TextArea } from '@/mastodon/components/form_fields';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import {
  COMPOSER_TEXTAREA_ID,
  focusComposerTextarea,
} from '@/mastodon/reducers/slices/composer';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { selectComposeType, selectSuggestions } from './selectors';
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
  const dispatch = useAppDispatch();

  // Suggestion hooks
  const onSuggestionFetch = useCallback(
    (token: string) => {
      dispatch(fetchComposeSuggestions(token));
    },
    [dispatch],
  );

  const onSuggestion: OnSuggestionSelect = useCallback(
    (tokenStart, token, suggestion) => {
      dispatch(
        selectComposeSuggestion(tokenStart, token, suggestion, ['text']),
      );
      focusComposerTextarea(true);
    },
    [dispatch],
  );

  const onSuggestionClear = useCallback(() => {
    dispatch(clearComposeSuggestions());
  }, [dispatch]);

  const suggestions = useAppSelector(selectSuggestions);
  const { textChange, focus, getToken, ...suggestionProps } =
    useAutosuggestMenu({
      suggestions,
      onSelect: onSuggestion,
      onFetch: onSuggestionFetch,
      onClear: onSuggestionClear,
    });

  // Suggestion state and refs
  const [textArea, setTextArea] = useState<HTMLTextAreaElement | null>(null); // The textarea itself.
  const [mirrorElement, setMirrorElement] = useState<HTMLElement | null>(null); // Reference to the mirror element.
  const [selectedText, setSelectedText] = useState(text); // The actual selected text inside the mirror.
  const [updatePopover, setUpdatePopover] = useState<(() => void) | null>(null); // Reference to the popover update callback.

  // Update the composer text and trigger suggestions.
  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));
      textChange(event);
    },
    [dispatch, textChange],
  );

  const onKeyDown: React.KeyboardEventHandler<HTMLTextAreaElement> =
    useCallback(
      (event) => {
        const key = normalizeKey(event.key);

        if (key === 'enter' && (event.ctrlKey || event.metaKey)) {
          onSubmit();
          event.preventDefault();
          onSuggestionClear();
        } else if (key === 'escape') {
          // Dismiss the suggestions if we're displaying any.
          if (suggestions.length > 0) {
            onSuggestionClear();
          } else {
            // Otherwise lose focus on the textarea.
            event.currentTarget.blur();
          }
        } else if (key === 'down') {
          focus(event);
        }
      },
      [onSubmit, onSuggestionClear, suggestions.length, focus],
    );

  // When the caret or selection changes, update the selected text and clear the composer if it doesn't include a token.
  const onSelect: React.ReactEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      const { token, startPosition } = getToken();
      if (token === null) {
        return;
      }

      const { selectionStart, value } = event.currentTarget;
      const tokenEnd = startPosition + token.length;
      setSelectedText(value.slice(0, tokenEnd)); // Only set the text up to the selected end point.

      if (selectionStart < startPosition || selectionStart > tokenEnd) {
        onSuggestionClear();
      }
    },
    [getToken, onSuggestionClear],
  );

  // Debounced callback to update the popover on scroll.
  const onTextAreaScroll = useThrottledCallback(() => {
    // Call the popover update callback. This enables the popover to adjust position with scroll.
    updatePopover?.();

    if (textArea && mirrorElement) {
      // Set top to scroll offset so bottom edge looks right.
      mirrorElement.style.setProperty('top', `${-1 * textArea.scrollTop}px`);

      const { height } = textArea.getBoundingClientRect();
      const offset = mirrorElement.offsetHeight - textArea.scrollTop;
      if (offset < 0 || offset > height) {
        onSuggestionClear();
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
      />

      <div className={classes.textareaMirror} ref={setMirrorElement}>
        {selectedText}
      </div>

      <AutosuggestMenu
        {...suggestionProps}
        reference={mirrorElement}
        updatePopoverCb={setUpdatePopover}
      />
    </div>
  );
};
