import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button/redesign';
import {
  focusComposerTextarea,
  openNewComposer,
  resetComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch } from '@/mastodon/store';

import classes from './modals.module.scss';

const ComposerCancelConfirmModal: React.FC<{ openNew?: boolean }> = ({
  openNew,
}) => {
  const dispatch = useAppDispatch();
  const handleDelete = useCallback(() => {
    if (openNew) {
      dispatch(openNewComposer({ force: true }));
    } else {
      dispatch(resetComposer());
    }
    dispatch(
      closeModal({ modalType: 'COMPOSER_DRAFT_DELETE', ignoreFocus: false }),
    );
  }, [dispatch, openNew]);
  const handleContinue = useCallback(() => {
    dispatch(
      closeModal({ modalType: 'COMPOSER_DRAFT_DELETE', ignoreFocus: false }),
    );
    requestAnimationFrame(() => {
      focusComposerTextarea();
    });
  }, [dispatch]);

  return (
    <div className={classes.root}>
      <h2 className={classes.title}>
        <FormattedMessage
          id='compose.cancel_modal.title'
          defaultMessage='Discard draft'
        />
      </h2>

      <FormattedMessage
        id='compose.cancel_modal.body'
        defaultMessage='You have a draft already in progress. What would you like to do?'
      />

      <div className={classes.footer}>
        <Button color='destructive' onClick={handleDelete}>
          <FormattedMessage
            id='compose.cancel_modal.delete'
            defaultMessage='Delete draft'
          />
        </Button>
        <Button color='neutral' onClick={handleContinue}>
          <FormattedMessage
            id='compose.cancel_modal.continue'
            defaultMessage='Continue draft'
          />
        </Button>
      </div>
    </div>
  );
};

// eslint-disable-next-line import/no-default-export -- Modals import from default
export default ComposerCancelConfirmModal;
