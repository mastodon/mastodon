import { defineMessages, useIntl } from 'react-intl';

import { IconButton } from '@/mastodon/components/icon_button';
import { createAppSelector, useAppSelector } from '@/mastodon/store';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

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
  },
  messageEdit: {
    id: 'compose_form.message.title.edit',
    defaultMessage: 'Edit message',
  },
});

const selectComposeFormTitle = createAppSelector(
  [selectComposeType, (state) => state.compose.get('id') as null | string],
  (type, id) => {
    return messages[`${type}${id ? 'Edit' : 'New'}`];
  },
);

export const ComposeFormHeader: React.FC<{ id?: string }> = ({ id }) => {
  const intl = useIntl();
  const titleMessage = useAppSelector(selectComposeFormTitle);

  return (
    <header className={classes.header}>
      <h2 id={id}>{intl.formatMessage(titleMessage)}</h2>
      <IconButton
        icon='close'
        iconComponent={CloseIcon}
        title={intl.formatMessage({
          id: 'lightbox.close',
          defaultMessage: 'Close',
        })}
      />
    </header>
  );
};
