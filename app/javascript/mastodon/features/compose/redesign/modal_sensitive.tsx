import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { changeComposeSpoilerness } from '@/mastodon/actions/compose';
import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalShell,
  ModalActions,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import {
  requestComposerFocus,
  submitComposer,
} from '@/mastodon/reducers/slices/composer';
import { useAppDispatch } from '@/mastodon/store';

const ComposerModalSensitive: React.FC<{ redirectOnSuccess?: boolean }> = ({
  redirectOnSuccess,
}) => {
  const dispatch = useAppDispatch();
  const onCancel = useCallback(() => {
    dispatch(requestComposerFocus());
    dispatch(
      closeModal({
        modalType: 'COMPOSER_ADD_CONTENT_WARNING',
        ignoreFocus: false,
      }),
    );
  }, [dispatch]);
  const onContinue = useCallback(() => {
    dispatch(changeComposeSpoilerness());
    dispatch(submitComposer({ redirectOnSuccess }));
    dispatch(
      closeModal({
        modalType: 'COMPOSER_ADD_CONTENT_WARNING',
        ignoreFocus: false,
      }),
    );
  }, [dispatch, redirectOnSuccess]);

  return (
    <ModalShell>
      <ModalTitle>
        <FormattedMessage
          id='compose.sensitive_modal.title'
          defaultMessage='Publish without content warning?'
        />
      </ModalTitle>

      <FormattedMessage
        id='compose.sensitive_modal.body'
        defaultMessage="You haven't added content warning text. If you publish now, your post will not be hidden behind a content warning."
      />

      <ModalActions>
        <Button variant='solid' color='destructive' onClick={onCancel}>
          <FormattedMessage
            id='compose.sensitive_modal.cancel'
            defaultMessage='Continue editing'
          />
        </Button>
        <Button variant='solid' onClick={onContinue}>
          <FormattedMessage
            id='compose.sensitive_modal.continue'
            defaultMessage='Publish without warning'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default ComposerModalSensitive;
