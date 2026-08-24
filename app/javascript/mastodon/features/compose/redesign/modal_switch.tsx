import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { changeComposeVisibility } from '@/mastodon/actions/compose_typed';
import { closeModal } from '@/mastodon/actions/modal';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

const ComposerModalSwitch: React.FC = () => {
  const dispatch = useAppDispatch();
  const handleBack = useCallback(() => {
    dispatch(
      closeModal({ modalType: 'COMPOSER_SWITCH_TO_POST', ignoreFocus: false }),
    );
  }, [dispatch]);

  const defaultPrivacy = useAppSelector(
    (state) =>
      (state.compose.get('default_privacy') as StatusVisibility | undefined) ??
      'public',
  );
  const handleContinue = useCallback(() => {
    dispatch(changeComposeVisibility(defaultPrivacy));
    dispatch(
      closeModal({ modalType: 'COMPOSER_SWITCH_TO_POST', ignoreFocus: false }),
    );
  }, [defaultPrivacy, dispatch]);

  return (
    <ModalShell maxWidth={400}>
      <ModalTitle>
        <FormattedMessage
          id='compose.switch_modal.title'
          defaultMessage='Convert to post?'
        />
      </ModalTitle>

      <FormattedMessage
        id='compose.switch_modal.body'
        defaultMessage='Your message has limited visibility. If you convert to a post, it will switch to your default post visibility.'
      />

      <ModalActions>
        <Button size='sm' onClick={handleBack}>
          <FormattedMessage
            id='compose.switch_modal.back'
            defaultMessage='Back'
          />
        </Button>

        <Button size='sm' variant='solid' onClick={handleContinue}>
          <FormattedMessage
            id='compose.switch_modal.continue'
            defaultMessage='Continue'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

// eslint-disable-next-line import/no-default-export
export default ComposerModalSwitch;
