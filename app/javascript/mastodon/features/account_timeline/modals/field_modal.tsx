import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from '@/mastodon/components/button';
import { EmojiHTML } from '@/mastodon/components/emoji/html';
import { ModalShell } from '@/mastodon/components/modal_shell';

import type { AccountField } from '../common';
import { useFieldHtml } from '../hooks/useFieldHtml';

import classes from './styles.module.css';

export const AccountFieldModal: FC<{
  onClose: () => void;
  field: AccountField;
}> = ({ onClose, field }) => {
  const handleLabelElement = useFieldHtml(field.nameHasEmojis);
  const handleValueElement = useFieldHtml(field.valueHasEmojis);
  return (
    <ModalShell>
      <ModalShell.Body>
        <EmojiHTML
          as='h2'
          htmlString={field.name_emojified}
          onElement={handleLabelElement}
        />
        <EmojiHTML
          as='p'
          htmlString={field.value_emojified}
          onElement={handleValueElement}
          className={classes.fieldValue}
        />
      </ModalShell.Body>
      <ModalShell.Actions>
        <Button onClick={onClose} plain>
          <FormattedMessage id='lightbox.close' defaultMessage='Close' />
        </Button>
      </ModalShell.Actions>
    </ModalShell>
  );
};
