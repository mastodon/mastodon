import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { resetCompose } from '@/mastodon/actions/compose';
import { quoteCompose } from '@/mastodon/actions/compose_typed';
import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalShell,
  ModalActions,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const ComposerQuoteAddConfirm: React.FC<{ statusId: string }> = ({
  statusId,
}) => {
  const dispatch = useAppDispatch();
  const status = useAppSelector((state) => state.statuses.get(statusId));
  const handleClose = useCallback(() => {
    dispatch(
      closeModal({
        modalType: 'COMPOSER_ADD_QUOTE',
        ignoreFocus: true,
      }),
    );
  }, [dispatch]);
  const handleAdd = useCallback(() => {
    if (status) {
      dispatch(quoteCompose(status));
    }
    handleClose();
  }, [dispatch, handleClose, status]);
  const handleDelete = useCallback(() => {
    dispatch(resetCompose());
    handleAdd();
  }, [dispatch, handleAdd]);

  return (
    <ModalShell maxWidth={400}>
      <ModalTitle>
        <FormattedMessage
          id='compose.quote_modal.title'
          defaultMessage='Draft in progress'
        />
      </ModalTitle>

      <FormattedMessage
        id='compose.cancel_modal.body'
        defaultMessage='You have a draft already in progress. What would you like to do?'
      />

      <ModalActions align='vertical'>
        <Button variant='solid' onClick={handleAdd}>
          <FormattedMessage
            id='compose.quote_modal.add'
            defaultMessage='Add quote to existing draft'
          />
        </Button>
        <Button variant='solid' color='destructive' onClick={handleDelete}>
          <FormattedMessage
            id='compose.quote_modal.delete'
            defaultMessage='Delete draft and start a new post'
          />
        </Button>
        <Button variant='ghost' onClick={handleClose}>
          <FormattedMessage
            id='compose.quote_modal.cancel'
            defaultMessage='Go back'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default ComposerQuoteAddConfirm;
