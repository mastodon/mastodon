import type React from 'react';
import { useCallback, useEffect, useId, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { LockSimpleOpenIcon } from '@phosphor-icons/react';
import type { TextareaAutosizeProps } from 'react-textarea-autosize';

import {
  changeCompose,
  changeComposeSpoilerness,
  changeComposeSpoilerText,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
} from '@/mastodon/actions/compose';
import {
  processPasteOrDrop,
  submitCompose,
} from '@/mastodon/actions/compose_typed';
import AutosuggestTextarea from '@/mastodon/components/autosuggest_textarea';
import {
  ToggleField,
  TextInputField,
} from '@/mastodon/components/form_fields/redesign';
import { Icon } from '@/mastodon/components/icon';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { ComposeFooter } from './footer';
import { ComposeFormHeader } from './header';
import { LanguageButton } from './language';
import { selectComposeCanSubmit, selectComposeState } from './selectors';
import classes from './styles.module.scss';
import { ComposeVisibility } from './visibility';

const messages = defineMessages({
  sensitive: {
    id: 'compose.sensitive',
    defaultMessage: 'Sensitive',
  },
  sensitiveText: {
    id: 'compose.sensitive.text',
    defaultMessage: 'Sensitive content description',
  },
  placeholder: {
    id: 'compose.post.placeholder',
    defaultMessage: 'What would you like to say?',
  },
  messagePlaceholder: {
    id: 'compose.message.placeholder',
    defaultMessage: 'Add your recipients and your message.',
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
  const {
    type,
    sensitive,
    sensitiveText,
    suggestions,
    text,
    lang,
    isSubmitting,
  } = useAppSelector(selectComposeState);

  const {
    textAreaRef,
    onSensitiveChange,
    onSensitiveTextChange,
    onSubmit,
    ...handlers
  } = useHandlers(redirectOnSuccess);

  const intl = useIntl();
  const titleId = useId();
  return (
    <form
      role='dialog'
      onSubmit={onSubmit}
      aria-labelledby={titleId}
      className={classes.root}
    >
      <ComposeFormHeader id={titleId} />
      <div className={classes.toolbar}>
        {type !== 'message' && <ComposeVisibility />}

        {type === 'message' && (
          <p className={classes.toolbarMessage}>
            <Icon id='lock-open' icon={LockSimpleOpenIcon} />
            <FormattedMessage
              id='compose.message.notice'
              defaultMessage='Messages are not end-to-end encrypted'
            />
          </p>
        )}

        <ToggleField
          label={intl.formatMessage(messages.sensitive)}
          checked={sensitive}
          onChange={onSensitiveChange}
          size='sm'
        />

        <LanguageButton />
      </div>

      {sensitive && (
        <TextInputField
          label={intl.formatMessage(messages.sensitiveText)}
          value={sensitiveText}
          onChange={onSensitiveTextChange}
          // eslint-disable-next-line jsx-a11y/no-autofocus -- Focuses on open
          autoFocus
        />
      )}

      <ComposeTextarea
        ref={textAreaRef}
        value={text}
        className={classes.textarea}
        // eslint-disable-next-line jsx-a11y/no-autofocus
        autoFocus={autoFocus}
        lang={lang}
        placeholder={intl.formatMessage(
          type === 'message'
            ? messages.messagePlaceholder
            : messages.placeholder,
        )}
        disabled={isSubmitting}
        suggestions={suggestions}
        {...handlers}
      />

      <ComposeFooter />
    </form>
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
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  const dispatch = useAppDispatch();

  // Focus the sensitive
  const isSensitive = useAppSelector((state) => !!state.compose.get('spoiler'));
  useEffect(() => {
    if (!isSensitive) {
      textAreaRef.current?.focus();
    }
  }, [isSensitive]);

  // Sensitive toggles
  const onSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);
  const onSensitiveTextChange: React.ChangeEventHandler<HTMLInputElement> =
    useCallback(
      (event) => {
        dispatch(changeComposeSpoilerText(event.target.value));
      },
      [dispatch],
    );

  // Submit status

  const canSubmit = useAppSelector(selectComposeCanSubmit);
  const onSubmit = useCallback(
    (event?: React.SubmitEvent) => {
      if (!canSubmit) {
        return;
      }
      dispatch(
        submitCompose({
          textareaValue: textAreaRef.current?.value,
          redirectOnSuccess,
        }),
      );

      if (event) {
        event.preventDefault();
      }
    },
    [canSubmit, dispatch, redirectOnSuccess],
  );

  // Text changes

  const onChange: React.ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      dispatch(changeCompose(event.target.value));
    },
    [dispatch],
  );
  const onKeyDown: React.KeyboardEventHandler<HTMLTextAreaElement> =
    useCallback(
      (event) => {
        if (
          event.key.toLowerCase() === 'enter' &&
          (event.ctrlKey || event.metaKey)
        ) {
          onSubmit();
          event.preventDefault();
        }
        blurOnEscape(event);
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

  // Suggestions

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
    textAreaRef,
    onSubmit,
    onChange,
    onKeyDown,
    onPaste,
    onDrop,
    onSensitiveChange,
    onSensitiveTextChange,
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
