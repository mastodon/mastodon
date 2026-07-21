import { useCallback, useId, useRef } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { changeComposeSpoilerness } from '@/mastodon/actions/compose';
import AutosuggestTextarea from '@/mastodon/components/autosuggest_textarea';
import { ToggleField } from '@/mastodon/components/form_fields';
import { IconButton } from '@/mastodon/components/icon_button';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import TranslateIcon from '@/material-icons/400-24px/translate.svg?react';

import { ComposeFormHeader } from './header';
import { selectComposeType } from './selectors';
import classes from './styles.module.scss';
import { ComposeVisibility } from './visibility';

const messages = defineMessages({
  changeLanguage: {
    id: 'compose.language.change',
    defaultMessage: 'Change language',
  },
  sensitive: {
    id: 'compose.sensitive',
    defaultMessage: 'Sensitive',
  },
});

export const RedesignComposeForm: React.FC = () => {
  const type = useAppSelector(selectComposeType);
  const sensitive = useAppSelector((state) => !!state.compose.get('spoiler'));

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const dispatch = useAppDispatch();
  const handleSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);

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
          onChange={handleSensitiveChange}
        />
        <IconButton
          icon='language'
          iconComponent={TranslateIcon}
          title={intl.formatMessage(messages.changeLanguage)}
        />
      </div>
      <AutosuggestTextarea ref={textareaRef} />
    </div>
  );
};
