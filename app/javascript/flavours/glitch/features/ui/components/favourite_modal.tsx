import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { Button } from '@/flavours/glitch/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/flavours/glitch/components/modal_shell/redesign';
import { StatusLikeIcon } from '@/flavours/glitch/components/status/icons';
import { QuotedStatus } from '@/flavours/glitch/components/status/quote';
import StarIcon from '@/material-icons/400-24px/star.svg?react';
import { Icon } from 'flavours/glitch/components/icon';

import classes from './boost_modal.module.scss';

export const FavouriteModal: React.FC<{
  statusId: string;
  onClose: () => void;
  onFavourite: () => void;
}> = ({ statusId, onFavourite, onClose }) => {
  const handleFavourite = useCallback(() => {
    onFavourite();
    onClose();
  }, [onClose, onFavourite]);

  return (
    <ModalShell maxWidth={600}>
      <ModalTitle className={classes.header}>
        <Icon icon={StatusLikeIcon} className={classes.headerIcon} />
        <FormattedMessage
          id='favourite_modal.favourite'
          defaultMessage='Favourite post?'
          tagName='span'
        />
        <span className={classes.subheader}>
          <FormattedMessage
            id='boost_modal.combo'
            defaultMessage='You can press {combo} to skip this next time'
            values={{
              combo: (
                <span className='hotkey-combination'>
                  <kbd>Shift</kbd>+<Icon id='star' icon={StarIcon} />
                </span>
              ),
            }}
          />
        </span>
      </ModalTitle>

      <QuotedStatus id={statusId} disableOpen />

      <ModalActions>
        <Button size='sm' variant='ghost' onClick={onClose}>
          <FormattedMessage
            id='confirmation_modal.cancel'
            defaultMessage='Cancel'
          />
        </Button>

        <Button size='sm' variant='solid' onClick={handleFavourite}>
          <FormattedMessage id='status.favourite' defaultMessage='Favourite' />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};
