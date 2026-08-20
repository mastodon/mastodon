import type React from 'react';
import { useCallback, useRef } from 'react';

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
import AutosuggestTextareaOriginal from '@/mastodon/components/autosuggest_textarea';
import { COMPOSER_TEXTAREA_ID } from '@/mastodon/reducers/slices/composer';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { selectComposeType } from './selectors';
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

type SuggestSelectedHandler = (
  position: number,
  token: string,
  suggestion: unknown,
) => void;

const AutosuggestTextarea =
  AutosuggestTextareaOriginal as React.ForwardRefExoticComponent<
    {
      suggestions: Immutable.List<unknown>;
      onSuggestionSelected: SuggestSelectedHandler;
      onSuggestionsClearRequested: () => void;
      onSuggestionsFetchRequested: (token: string) => void;
    } & TextareaAutosizeProps &
      React.RefAttributes<HTMLTextAreaElement>
  >;

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
    suggestions: compose.get(
      'suggestions',
    ) as unknown as Immutable.List<unknown>,
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
  const { suggestions, text, lang, isSubmitting } = useAppSelector(
    selectComposeTextState,
  );

  const dispatch = useAppDispatch();
  const onClickWrapper: React.MouseEventHandler<HTMLDivElement> = useCallback(
    (event) => {
      if (event.target instanceof HTMLDivElement) {
        event.target.querySelector('textarea')?.focus();
      }
    },
    [],
  );
  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));
    },
    [dispatch],
  );
  const onKeyDown: React.KeyboardEventHandler<HTMLTextAreaElement> =
    useCallback(
      (event) => {
        const key = event.key.toLowerCase();
        if (key === 'enter' && (event.ctrlKey || event.metaKey)) {
          onSubmit();
          event.preventDefault();
        } else if (['esc', 'escape'].includes(key)) {
          event.currentTarget.blur();
        }
      },
      [onSubmit],
    );
  const onPaste: React.ClipboardEventHandler = useCallback(
    (event) => {
      if (event.clipboardData.files.length === 1) {
        event.preventDefault();
      }
      dispatch(processPasteOrDrop(event.clipboardData));
    },
    [dispatch],
  );
  const onDrop: React.DragEventHandler = useCallback(
    (event) => {
      if (event.dataTransfer.files.length === 1) {
        event.preventDefault();
      }
      dispatch(processPasteOrDrop(event.dataTransfer));
    },
    [dispatch],
  );
  const onSuggestionsFetchRequested = useCallback(
    (token: string) => {
      dispatch(fetchComposeSuggestions(token));
    },
    [dispatch],
  );
  const onSuggestionsClearRequested = useCallback(() => {
    dispatch(clearComposeSuggestions());
  }, [dispatch]);
  const onSuggestionSelected: SuggestSelectedHandler = useCallback(
    (position, token, suggestion) => {
      dispatch(selectComposeSuggestion(position, token, suggestion, ['text']));
    },
    [dispatch],
  );

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  return (
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions -- This just moves focus to the textarea.
    <div
      onClick={onClickWrapper}
      className={classNames(className, classes.textareaWrapper)}
    >
      <AutosuggestTextarea
        {...props}
        id={COMPOSER_TEXTAREA_ID}
        ref={textareaRef}
        value={text}
        lang={lang}
        placeholder={intl.formatMessage(
          type === 'message'
            ? messages.messagePlaceholder
            : messages.placeholder,
        )}
        disabled={disabled || isSubmitting}
        suggestions={suggestions}
        onSuggestionsFetchRequested={onSuggestionsFetchRequested}
        onSuggestionsClearRequested={onSuggestionsClearRequested}
        onSuggestionSelected={onSuggestionSelected}
        onKeyDown={onKeyDown}
        onDrop={onDrop}
        onPaste={onPaste}
        onChange={onChange}
      />
    </div>
  );
};
