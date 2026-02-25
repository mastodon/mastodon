import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import { EmojiHTML } from '@/mastodon/components/emoji/html';

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
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__confirmation'>
          <EmojiHTML
            as='p'
            htmlString={field.name_emojified}
            onElement={handleLabelElement}
          />
          <EmojiHTML
            as='p'
            htmlString={field.value_emojified}
            onElement={handleValueElement}
            className={classes.fieldValue}
          />
        </div>
      </div>
      <div className='safety-action-modal__bottom'>
        <div className='safety-action-modal__actions'>
          <button onClick={onClose} className='link-button' type='button'>
            <FormattedMessage id='lightbox.close' defaultMessage='Close' />
          </button>
        </div>
      </div>
    </div>
  );
};
