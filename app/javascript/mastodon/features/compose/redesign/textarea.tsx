import type React from 'react';
import { useCallback, useEffect, useRef } from 'react';

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
import type { OnSuggestionSelect } from '@/mastodon/components/autosuggest/hooks';
import { useAutosuggestFloatingMenu } from '@/mastodon/components/autosuggest/hooks';
import { AutosuggestMenu } from '@/mastodon/components/autosuggest/list';
import { TextArea } from '@/mastodon/components/form_fields';
import { useScrollSensor } from '@/mastodon/hooks/useScrollSensor';
import {
  clearComposerErrors,
  clearComposerFocusRequest,
  COMPOSER_TEXTAREA_ID,
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
  TextareaAutosizeProps,
  | 'placeholder'
  | 'onFocus'
  | 'onBlur'
  | 'onPaste'
  | 'onDrop'
  | 'onChange'
  | 'onKeyDown'
> & { beforeTextArea?: React.ReactNode };

const selectComposeTextState = createAppSelector(
  [(state) => state.compose],
  (compose) => ({
    text: compose.get('text') as string,
    lang: compose.get('language') as string,
    isSubmitting: !!compose.get('is_submitting'),
  }),
);

export const ComposeTextarea: React.FC<ComposeTextareaProps> = ({
  className,
  disabled,
  children,
  beforeTextArea,
  ...props
}) => {
  const intl = useIntl();

  // Selectors
  const type = useAppSelector(selectComposeType);
  const { text, lang, isSubmitting } = useAppSelector(selectComposeTextState);
  const dispatch = useAppDispatch();

  // Suggestion logic
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
    },
    [dispatch],
  );

  const onSuggestionClear = useCallback(() => {
    dispatch(clearComposeSuggestions());
  }, [dispatch]);

  const suggestions = useAppSelector(selectSuggestions);
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  // Applies a focus/selection requested from elsewhere (e.g. reply, mention) once this textarea exists,
  // which also covers it not being mounted yet when the request was made (it's lazy-loaded).
  const pendingFocus = useAppSelector((state) => state.composer.pendingFocus);
  useEffect(() => {
    if (!pendingFocus) {
      return;
    }

    const { selection } = pendingFocus;
    if (selection) {
      textAreaRef.current?.setSelectionRange(selection.start, selection.end);
    }
    textAreaRef.current?.focus({ preventScroll: true });
    dispatch(clearComposerFocusRequest());
  }, [pendingFocus, dispatch]);

  const {
    onTextChange,
    mirror,
    sourceProps: fullSourceProps,
    suggestProps,
  } = useAutosuggestFloatingMenu({
    suggestions,
    text,
    lang,
    className: classes.textareaMirror,
    sourceRef: textAreaRef,
    onSelect: onSuggestion,
    onFetch: onSuggestionFetch,
    onClear: onSuggestionClear,
  });

  const { onScroll, ...sourceProps } = fullSourceProps;

  // Update the composer text and trigger suggestions.
  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));
      dispatch(clearComposerErrors());
      onTextChange(event);
    },
    [dispatch, onTextChange],
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

  const { sensor, isInViewport } = useScrollSensor({
    placement: 'bottom',
    tolerance: 10,
  });

  return (
    <div
      className={classes.textareaWrapper}
      data-scroll-down={!isInViewport}
      onScrollCapture={onScroll} // Requires capture so it fires before TextArea.
    >
      {beforeTextArea}

      <TextArea
        {...props}
        dir='auto'
        id={COMPOSER_TEXTAREA_ID}
        className={classNames(className, classes.textarea)}
        autoSize
        ref={textAreaRef}
        value={text}
        placeholder={intl.formatMessage(
          type === 'message'
            ? messages.messagePlaceholder
            : messages.placeholder,
        )}
        disabled={disabled || isSubmitting}
        onDrop={onPasteOrDrop}
        onPaste={onPasteOrDrop}
        onChange={onChange}
        {...sourceProps}
      />

      {mirror}

      <AutosuggestMenu {...suggestProps} maxWidth={280} />

      {children}

      {sensor}
    </div>
  );
};
