import type { FC } from 'react';
import { useCallback } from 'react';

import { openModal } from '@/mastodon/actions/modal';
import { useAppDispatch } from '@/mastodon/store';

import { EditButton, DeleteIconButton } from './edit_button';

export const AccountFieldActions: FC<{ item: string; id: string }> = ({
  item,
  id,
}) => {
  const dispatch = useAppDispatch();
  const handleEdit = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_EDIT',
        modalProps: { fieldKey: id },
      }),
    );
  }, [dispatch, id]);
  const handleDelete = useCallback(() => {
    dispatch(
      openModal({
        modalType: 'ACCOUNT_EDIT_FIELD_DELETE',
        modalProps: { fieldKey: id },
      }),
    );
  }, [dispatch, id]);

  return (
    <>
      <EditButton item={item} edit onClick={handleEdit} />
      <DeleteIconButton item={item} onClick={handleDelete} />
    </>
  );
};
