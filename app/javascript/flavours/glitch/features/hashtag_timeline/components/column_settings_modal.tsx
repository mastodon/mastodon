import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/flavours/glitch/actions/modal';
import { Button } from '@/flavours/glitch/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/flavours/glitch/components/modal_shell/redesign';
import { useAppDispatch } from '@/flavours/glitch/store';

import ColumnSettingsContainer from '../containers/column_settings_container';

const HashtagSettingsModal: React.FC<{ columnId: string }> = ({ columnId }) => {
  const dispatch = useAppDispatch();

  const handleCloseModal = useCallback(() => {
    void dispatch(
      closeModal({ modalType: 'HASHTAG_SETTINGS', ignoreFocus: false }),
    );
  }, [dispatch]);

  return (
    <ModalShell>
      <ModalTitle onClose={handleCloseModal}>
        <FormattedMessage
          id='hashtags.add_more_tags_to_column'
          defaultMessage='Add more tags to column'
        />
      </ModalTitle>
      <ColumnSettingsContainer columnId={columnId} />
      <ModalActions>
        <Button variant='solid' color='accent' onClick={handleCloseModal}>
          <FormattedMessage id='alt_text_modal.done' defaultMessage='Done' />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

export default HashtagSettingsModal;
