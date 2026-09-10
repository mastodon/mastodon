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
        description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
      />

      <ModalActions>
        <Button onClick={handleBack}>
          <FormattedMessage
            id='compose.switch_modal.back'
            defaultMessage='Back'
          />
        </Button>

        <Button variant='solid' onClick={handleContinue}>
          <FormattedMessage
            id='compose.switch_modal.continue'
            defaultMessage='Continue'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default ComposerModalSwitch;
