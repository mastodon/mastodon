import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import {
  openNewComposer,
  requestComposerFocus,
  resetComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const ComposerModalCancelConfirm: React.FC<{ openNew?: boolean }> = ({
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
    dispatch(requestComposerFocus());
  }, [dispatch]);

  const isEditing = useAppSelector((state) => !!state.compose.get('id'));

  return (
    <ModalShell>
      <ModalTitle>
        {isEditing ? (
          <FormattedMessage
            id='compose.cancel_modal.edit.title'
            defaultMessage='Unsaved changes'
          />
        ) : (
          <FormattedMessage
            id='compose.cancel_modal.title'
            defaultMessage='Discard draft'
          />
        )}
      </ModalTitle>

      {isEditing ? (
        <FormattedMessage
          id='compose.cancel_modal.edit.body'
          defaultMessage='You were editing a post. What would you like to do?'
        />
      ) : (
        <FormattedMessage
          id='compose.cancel_modal.body'
          defaultMessage='You have a draft already in progress. What would you like to do?'
        />
      )}

      <ModalActions>
        <Button variant='solid' color='destructive' onClick={handleDelete}>
          {isEditing ? (
            <FormattedMessage
              id='compose.cancel_modal.edit.delete'
              defaultMessage='Discard changes'
            />
          ) : (
            <FormattedMessage
              id='compose.cancel_modal.delete'
              defaultMessage='Delete draft'
            />
          )}
        </Button>
        <Button variant='solid' onClick={handleContinue}>
          {isEditing ? (
            <FormattedMessage
              id='compose.cancel_modal.edit.continue'
              defaultMessage='Continue editing'
            />
          ) : (
            <FormattedMessage
              id='compose.cancel_modal.continue'
              defaultMessage='Continue draft'
            />
          )}
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default ComposerModalCancelConfirm;
