import { useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { showAlert } from 'mastodon/actions/alerts';
import { openModal } from 'mastodon/actions/modal';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import type { BaseConfirmationModalProps } from 'mastodon/features/ui/components/confirmation_modals/confirmation_modal';
import { ConfirmationModal } from 'mastodon/features/ui/components/confirmation_modals/confirmation_modal';
import { me } from 'mastodon/initial_state';
import { revokeCollectionInclusion } from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

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

export function useConfirmRevoke(collection?: ApiCollectionJSON) {
  const dispatch = useAppDispatch();
  const { id, items = [] } = collection ?? {};
  const ownCollectionItemId = items.find((item) => item.account_id === me)?.id;

  return useCallback(() => {
    void dispatch(
      openModal({
        modalType: 'REVOKE_COLLECTION_INCLUSION',
        modalProps: {
          collectionId: id,
          collectionItemId: ownCollectionItemId,
        },
      }),
    );
  }, [dispatch, id, ownCollectionItemId]);
}

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
