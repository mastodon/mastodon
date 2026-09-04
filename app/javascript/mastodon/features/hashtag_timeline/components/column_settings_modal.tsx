import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { closeModal } from '@/mastodon/actions/modal';
import { Button } from '@/mastodon/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import { useAppDispatch } from '@/mastodon/store';

import ColumnSettingsContainer from '../containers/column_settings_container';

const HashtagSettingsModal: React.FC<{ columnId: string; tagId: string }> = ({
  columnId,
  tagId,
}) => {
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
          defaultMessage='Add more tags to #{tag}'
          values={{ tag: tagId }}
        />
      </ModalTitle>
      <ColumnSettingsContainer columnId={columnId} />
      <ModalActions>
        <Button variant='solid' onClick={handleCloseModal}>
          <FormattedMessage id='alt_text_modal.done' defaultMessage='Done' />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

// eslint-disable-next-line import/no-default-export
export default HashtagSettingsModal;
