import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { showAlert } from 'flavours/glitch/actions/alerts';
import type { BaseConfirmationModalProps } from 'flavours/glitch/features/ui/components/confirmation_modals/confirmation_modal';
import { ConfirmationModal } from 'flavours/glitch/features/ui/components/confirmation_modals/confirmation_modal';
import { revokeCollectionInclusion } from 'flavours/glitch/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'flavours/glitch/store';

const messages = defineMessages({
  revokeCollectionInclusionTitle: {
    id: 'confirmations.revoke_collection_inclusion.title',
    defaultMessage: 'Remove yourself from this collection?',
  },
  revokeCollectionInclusionMessage: {
    id: 'confirmations.revoke_collection_inclusion.message',
    defaultMessage:
      "This action is permanent, and the curator won't be able to re-add you to the collection later on.",
  },
  revokeCollectionInclusionConfirm: {
    id: 'confirmations.revoke_collection_inclusion.confirm',
    defaultMessage: 'Remove me',
  },
});

export const RevokeCollectionInclusionModal: React.FC<
  {
    collectionId: string;
    collectionItemId: string;
  } & BaseConfirmationModalProps
> = ({ collectionId, collectionItemId, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const collectionName = useAppSelector(
    (state) => state.collections.collections[collectionId]?.name,
  );

  const onConfirm = useCallback(async () => {
    try {
      await dispatch(
        revokeCollectionInclusion({
          collectionId,
          itemId: collectionItemId,
        }),
      ).unwrap();

      dispatch(
        showAlert({
          message: intl.formatMessage(
            {
              id: 'collections.revoke_inclusion.confirmation',
              defaultMessage: 'You\'ve been removed from "{collection}"',
            },
            {
              collection: collectionName,
            },
          ),
        }),
      );
    } catch {
      dispatch(
        showAlert({
          message: intl.formatMessage({
            id: 'collections.revoke_inclusion.error',
            defaultMessage: 'There was an error, please try again later.',
          }),
        }),
      );
    }
  }, [dispatch, collectionId, collectionName, collectionItemId, intl]);

  return (
    <ConfirmationModal
      title={intl.formatMessage(messages.revokeCollectionInclusionTitle)}
      message={intl.formatMessage(messages.revokeCollectionInclusionMessage)}
      confirm={intl.formatMessage(messages.revokeCollectionInclusionConfirm)}
      onConfirm={onConfirm}
      onClose={onClose}
    />
  );
};
