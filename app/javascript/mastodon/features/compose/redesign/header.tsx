import { useCallback } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { ArrowsOutSimpleIcon, MinusIcon, XIcon } from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button/redesign';
import {
  closeComposer,
  minimizeComposerToggle,
  selectIsMinimized,
} from '@/mastodon/reducers/slices/composer';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { selectComposeType } from './selectors';
import classes from './styles.module.scss';

const messages = defineMessages({
  postNew: {
    id: 'compose.post.title.new',
    defaultMessage: 'New post',
  },
  postEdit: {
    id: 'compose.post.title.edit',
    defaultMessage: 'Edit post',
  },
  replyNew: {
    id: 'compose.reply.title.new',
    defaultMessage: 'New reply',
  },
  replyEdit: {
    id: 'compose_form.reply.title.edit',
    defaultMessage: 'Edit reply',
  },
  messageNew: {
    id: 'compose_form.message.title.new',
    defaultMessage: 'New message',
    description:
      'Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.',
  },
  messageEdit: {
    id: 'compose_form.message.title.edit',
    defaultMessage: 'Edit message',
    description:
      'Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.',
  },
});

const selectComposeFormTitle = createAppSelector(
  [selectComposeType, (state) => state.compose.get('id') as null | string],
  (type, id) => {
    return messages[`${type}${id ? 'Edit' : 'New'}`];
  },
);

export const ComposeFormHeader: React.FC<{
  id?: string;
  noMinimize?: boolean;
}> = ({ id, noMinimize }) => {
  const intl = useIntl();
  const titleMessage = useAppSelector(selectComposeFormTitle);
  const isMinimized = useAppSelector(selectIsMinimized);

  const dispatch = useAppDispatch();
  const onClose = useCallback(() => {
    dispatch(closeComposer());
  }, [dispatch]);
  const onMinimize = useCallback(() => {
    dispatch(minimizeComposerToggle());
  }, [dispatch]);

  return (
    <header className={classes.header}>
      <h2 id={id}>{intl.formatMessage(titleMessage)}</h2>

      {!noMinimize && (
        <IconButton
          size='sm'
          variant='ghost'
          icon={isMinimized ? ArrowsOutSimpleIcon : MinusIcon}
          onClick={onMinimize}
        >
          {isMinimized ? (
            <FormattedMessage
              id='compose.expand'
              defaultMessage='Show composer'
            />
          ) : (
            <FormattedMessage
              id='compose.minimize'
              defaultMessage='Minimize composer'
            />
          )}
        </IconButton>
      )}

      <IconButton icon={XIcon} variant='ghost' size='sm' onClick={onClose}>
        <FormattedMessage id='lightbox.close' defaultMessage='Close' />
      </IconButton>
    </header>
  );
};
