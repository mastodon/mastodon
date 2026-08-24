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
  focusComposerTextarea,
  openNewComposer,
  resetComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch } from '@/mastodon/store';

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
    focusComposerTextarea(true);
  }, [dispatch]);

  return (
    <ModalShell>
      <ModalTitle>
        <FormattedMessage
          id='compose.cancel_modal.title'
          defaultMessage='Discard draft'
        />
      </ModalTitle>

      <FormattedMessage
        id='compose.cancel_modal.body'
        defaultMessage='You have a draft already in progress. What would you like to do?'
      />

      <ModalActions>
        <Button variant='solid' color='destructive' onClick={handleDelete}>
          <FormattedMessage
            id='compose.cancel_modal.delete'
            defaultMessage='Delete draft'
          />
        </Button>
        <Button variant='solid' onClick={handleContinue}>
          <FormattedMessage
            id='compose.cancel_modal.continue'
            defaultMessage='Continue draft'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

// eslint-disable-next-line import/no-default-export -- Modals import from default
export default ComposerModalCancelConfirm;
