import { useCallback, useRef } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { EyeSlashIcon, PlusIcon } from '@phosphor-icons/react';

import { changeComposeSpoilerText } from '@/mastodon/actions/compose';
import { TextInput } from '@/mastodon/components/form_fields';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import { Icon } from '@/mastodon/components/icon';
import { useToggle } from '@/mastodon/hooks/useToggle';
import {
  clearComposerErrors,
  requestComposerFocus,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import { isKeyComposing } from '@/mastodon/utils/events';

import classes from '../styles.module.scss';

import { selectComposeSensitive } from './selectors';

const messages = defineMessages({
  placeholder: {
    id: 'compose.sensitive.placeholder',
    defaultMessage: 'Add content warning…',
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

  const onChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      dispatch(changeComposeSpoilerText(event.target.value));
      dispatch(clearComposerErrors(['missing-content-warning']));
    },
    [dispatch],
  );
  const onKeyDown: React.KeyboardEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      if (isKeyComposing(event)) {
        return;
      }

      const key = normalizeKey(event.key);
      if (key === 'enter') {
        event.preventDefault();
        dispatch(requestComposerFocus());
        return false;
      } else if (key === 'escape') {
        event.preventDefault();
        inputRef.current?.blur();
        return false;
      }
      return;
    },
    [dispatch],
  );

  const [focused, { onTrue: onFocus, onFalse: onBlur }] = useToggle();

  return (
    <div className={classes.sensitiveWrapper} data-contents={!!sensitiveText}>
      <Icon icon={focused || sensitive ? EyeSlashIcon : PlusIcon} />
      <TextInput
        {...props}
        autoFocus
        ref={inputRef}
        aria-required='true'
        value={sensitiveText}
        onChange={onChange}
        onKeyDown={onKeyDown}
        onFocus={onFocus}
        onBlur={onBlur}
        className={classes.sensitive}
        placeholder={intl.formatMessage(messages.placeholder)}
      />
    </div>
  );
};
