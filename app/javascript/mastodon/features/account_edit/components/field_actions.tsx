import type { FC } from 'react';
import { useCallback } from 'react';

import { openModal } from '@/mastodon/actions/modal';
import type { ApiAccountFieldJSON } from '@/mastodon/api_types/accounts';
import { useAppDispatch } from '@/mastodon/store';

import { EditButton, DeleteIconButton } from './edit_button';

export const AccountFieldActions: FC<
  ApiAccountFieldJSON & { item: string }
> = ({ item, ...field }) => {
  const dispatch = useAppDispatch();
  const handleEdit = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_EDIT',
        modalProps: { field },
      }),
    );
  }, [dispatch, field]);
  const handleDelete = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_DELETE',
        modalProps: { field },
      }),
    );
  }, [dispatch, field]);

  return (
    <>
      <EditButton item={item} edit onClick={handleEdit} />
      <DeleteIconButton item={item} onClick={handleDelete} />
    </>
  );
};
