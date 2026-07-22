import type React from 'react';
import { useCallback, useId, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import type { TextareaAutosizeProps } from 'react-textarea-autosize';

import {
  changeCompose,
  changeComposeSpoilerness,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
} from '@/mastodon/actions/compose';
import {
  processPasteOrDrop,
  submitCompose,
} from '@/mastodon/actions/compose_typed';
import AutosuggestTextarea from '@/mastodon/components/autosuggest_textarea';
import { IconButton } from '@/mastodon/components/button/redesign';
import { ToggleField } from '@/mastodon/components/form_fields';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import TranslateIcon from '@/material-icons/400-24px/translate.svg?react';

import { ComposeFormHeader } from './header';
import { selectComposeCanSubmit, selectComposeState } from './selectors';
import classes from './styles.module.scss';
import { ComposeVisibility } from './visibility';

const messages = defineMessages({
  sensitive: {
    id: 'compose.sensitive',
    defaultMessage: 'Sensitive',
  },
});

interface RedesignComposeFormProps {
  autoFocus?: boolean;
  redirectOnSuccess?: boolean;
}

export const RedesignComposeForm: React.FC<RedesignComposeFormProps> = ({
  autoFocus,
  redirectOnSuccess,
}) => {
  const { type, sensitive, suggestions, text, lang, isSubmitting } =
    useAppSelector(selectComposeState);

  const { ref, onSensitiveChange, ...handlers } =
    useHandlers(redirectOnSuccess);

  const intl = useIntl();
  const titleId = useId();
  return (
    <div role='dialog' aria-labelledby={titleId} className={classes.root}>
      <ComposeFormHeader id={titleId} />
      <div className={classes.toolbar}>
        {type !== 'message' && <ComposeVisibility />}
        {type === 'message' && (
          <div>
            <FormattedMessage
              id='compose.message.notice'
              defaultMessage='Messages are not end-to-end encrypted'
            />
          </div>
        )}
        <ToggleField
          label={intl.formatMessage(messages.sensitive)}
          checked={sensitive}
          onChange={onSensitiveChange}
        />
        <IconButton icon={TranslateIcon}>
          <FormattedMessage
            id='compose.language.change'
            defaultMessage='Change language'
          />
        </IconButton>
      </div>
      <ComposeTextarea
        ref={ref}
        value={text}
        // eslint-disable-next-line jsx-a11y/no-autofocus
        autoFocus={autoFocus}
        lang={lang}
        // placeholder={intl.formatMessage(messages.placeholder)}
        disabled={isSubmitting}
        suggestions={suggestions}
        {...handlers}
      />
    </div>
  );
};

type SuggestSelectedHandler = (
  position: number,
  token: string,
  suggestion: unknown,
) => void;

const ComposeTextarea = AutosuggestTextarea as React.ForwardRefExoticComponent<
  {
    suggestions: Immutable.List<unknown>;
    onSuggestionSelected: SuggestSelectedHandler;
    onSuggestionsClearRequested: () => void;
    onSuggestionsFetchRequested: (token: string) => void;
  } & TextareaAutosizeProps &
    React.RefAttributes<HTMLTextAreaElement>
>;

function useHandlers(redirectOnSuccess?: boolean) {
  const ref = useRef<HTMLTextAreaElement>(null);

  const dispatch = useAppDispatch();
  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));
    },
    [dispatch],
  );
  const onSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);

  const canSubmit = useAppSelector(selectComposeCanSubmit);
  const handleSubmit = useCallback(
    (event?: React.SubmitEvent) => {
      if (!canSubmit) {
        return;
      }
      dispatch(
        submitCompose({
          textareaValue: ref.current?.value,
          redirectOnSuccess,
        }),
      );

      if (event) {
        event.preventDefault();
      }
    },
    [canSubmit, dispatch, redirectOnSuccess],
  );
  const onKeyDown: React.KeyboardEventHandler<HTMLTextAreaElement> =
    useCallback(
      (event) => {
        if (
          event.key.toLowerCase() === 'enter' &&
          (event.ctrlKey || event.metaKey)
        ) {
          handleSubmit();
          event.preventDefault();
        }
        blurOnEscape(event);
      },
      [handleSubmit],
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
      dispatch(selectComposeSuggestion(position, token, suggestion));
    },
    [dispatch],
  );

  return {
    ref,
    onKeyDown,
    onChange,
    onPaste,
    onDrop,
    onSensitiveChange,
    onSuggestionsFetchRequested,
    onSuggestionsClearRequested,
    onSuggestionSelected,
  };
}

function blurOnEscape(event: React.KeyboardEvent<HTMLTextAreaElement>) {
  if (
    ['esc', 'escape'].includes(event.key.toLowerCase()) &&
    event.target instanceof HTMLTextAreaElement
  ) {
    event.target.blur();
  }
}
