import type { FC } from 'react';

import { FormattedMessage } from 'react-intl';

import type { AccountField } from '../common';

import classes from './styles.module.css';

export const AccountFieldModal: FC<{
  onClose: () => void;
  field: AccountField;
}> = ({ onClose, field }) => {
  return (
    <div className='modal-root__modal safety-action-modal'>
      <div className='safety-action-modal__top'>
        <div className='safety-action-modal__confirmation'>
          <p>{field.name}</p>
          <p className={classes.fieldValue}>{field.value}</p>
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
