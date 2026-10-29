import { useCallback, useEffect, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { TrashIcon } from '@phosphor-icons/react';

import { changeComposeSpoilerText } from '@/mastodon/actions/compose';
import { IconButton } from '@/mastodon/components/button/redesign';
import { FormFieldWrapper } from '@/mastodon/components/form_fields';
import { TextInput } from '@/mastodon/components/form_fields/redesign';
import {
  matchesKeyCode,
  normalizeKey,
} from '@/mastodon/components/hotkeys/utils';
import {
  clearComposerErrors,
  toggleContentWarning,
  requestComposerFocus,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectComposeSensitive } from './selectors';
import classes from './styles.module.scss';

const messages = defineMessages({
  sensitiveText: {
    id: 'compose.sensitive.text',
    defaultMessage: 'Content warning',
  },
  sensitiveMissing: {
    id: 'form_error.blank',
    defaultMessage: 'Field cannot be blank.',
  },
});

export const ComposeSensitiveField: React.FC<
  React.ComponentPropsWithoutRef<'input'>
> = (props) => {
  const { sensitive, sensitiveText } = useAppSelector(selectComposeSensitive);

  const intl = useIntl();
  const inputRef = useRef<HTMLInputElement>(null);
  const dispatch = useAppDispatch();
  const isSensitive = useAppSelector((state) => !!state.compose.get('spoiler'));
  useEffect(() => {
    if (!isSensitive) {
      dispatch(requestComposerFocus());
    }
  }, [isSensitive, dispatch]);

  const errors = useAppSelector((state) => state.composer.publishErrors);

  const onChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      dispatch(changeComposeSpoilerText(event.target.value));
      dispatch(clearComposerErrors(['missing-content-warning']));
    },
    [dispatch],
  );
  const onKeyDown: React.KeyboardEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const key = normalizeKey(event.key);
      if (key === 'enter') {
        event.preventDefault();
        dispatch(requestComposerFocus());
        return false;
      } else if (key === 'escape') {
        event.preventDefault();
        inputRef.current?.blur();
        return false;
      } else if (matchesKeyCode('x', event.code) && event.altKey) {
        event.preventDefault();
        dispatch(toggleContentWarning());
        return false;
      }
      return;
    },
    [dispatch],
  );
  const onRemove = useCallback(() => {
    dispatch(toggleContentWarning());
  }, [dispatch]);

  if (!sensitive) {
    return null;
  }

  return (
    <FormFieldWrapper
      className={classes.sensitiveWrapper}
      status={
        errors.includes('missing-content-warning')
          ? {
              variant: 'error',
              message: intl.formatMessage(messages.sensitiveMissing),
            }
          : undefined
      }
      label={intl.formatMessage(messages.sensitiveText)}
    >
      {(inputProps) => (
        <>
          <TextInput
            {...props}
            {...inputProps}
            autoFocus
            ref={inputRef}
            aria-required='true'
            value={sensitiveText}
            onChange={onChange}
            onKeyDown={onKeyDown}
            className={classes.sensitive}
          />

          <IconButton
            size='sm'
            icon={TrashIcon}
            onClick={onRemove}
            color='destructive'
          >
            <FormattedMessage
              id='compose.sensitive.delete'
              defaultMessage='Remove content warning'
            />
          </IconButton>
        </>
      )}
    </FormFieldWrapper>
  );
};
