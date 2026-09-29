import { useCallback, useEffect } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { changeComposeSpoilerText } from '@/mastodon/actions/compose';
import { TextInputField } from '@/mastodon/components/form_fields';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import { requestComposerFocus } from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectComposeSensitive } from './selectors';

const messages = defineMessages({
  sensitiveText: {
    id: 'compose.sensitive.text',
    defaultMessage: 'Content warning',
  },
});

export const ComposeSensitiveField: React.FC = () => {
  const { sensitive, sensitiveText } = useAppSelector(selectComposeSensitive);

  const intl = useIntl();
  const dispatch = useAppDispatch();
  const isSensitive = useAppSelector((state) => !!state.compose.get('spoiler'));
  useEffect(() => {
    if (!isSensitive) {
      dispatch(requestComposerFocus());
    }
  }, [isSensitive, dispatch]);

  const onChange: React.ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      dispatch(changeComposeSpoilerText(event.target.value));
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
      }
      return;
    },
    [dispatch],
  );
  if (!sensitive) {
    return null;
  }
  return (
    <TextInputField
      label={intl.formatMessage(messages.sensitiveText)}
      value={sensitiveText}
      onChange={onChange}
      onKeyDown={onKeyDown}
      // eslint-disable-next-line jsx-a11y/no-autofocus -- Focuses on open
      autoFocus
    />
  );
};
