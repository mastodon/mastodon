import { useCallback } from 'react';
import type { FC } from 'react';

import classes from '../styles.module.scss';

import { DeleteIconButton, EditButton } from './edit_button';

interface AnyItem {
  id: string;
  name: string;
}

interface AccountEditItemListProps<Item extends AnyItem = AnyItem> {
  renderItem?: (item: Item) => React.ReactNode;
  items: Item[];
  onEdit?: (item: Item) => void;
  onDelete?: (item: Item) => void;
}

export const AccountEditItemList: FC<AccountEditItemListProps> = ({
  renderItem,
  items,
  onEdit,
  onDelete,
}) => {
  if (items.length === 0) {
    return null;
  }

  return (
    <ul className={classes.itemList}>
      {items.map((item) => (
        <li key={item.id}>
          <span>{renderItem?.(item) ?? item.name}</span>
          <AccountEditItemButtons
            onDelete={onDelete}
            onEdit={onEdit}
            item={item}
          />
        </li>
      ))}
    </ul>
  );
};

type AccountEditItemButtonsProps<Item extends AnyItem = AnyItem> = Pick<
  AccountEditItemListProps<Item>,
  'onEdit' | 'onDelete'
> & { item: Item };

const AccountEditItemButtons: FC<AccountEditItemButtonsProps> = ({
  item,
  onDelete,
  onEdit,
}) => {
  const handleEdit = useCallback(() => {
    onEdit?.(item);
  }, [item, onEdit]);
  const handleDelete = useCallback(() => {
    onDelete?.(item);
  }, [item, onDelete]);

  if (!onEdit && !onDelete) {
    return null;
  }

  return (
    <div className={classes.itemListButtons}>
      {onEdit && <EditButton onClick={handleEdit} item={item.name} edit />}
      {onDelete && <DeleteIconButton onClick={handleDelete} item={item.name} />}
    </div>
  );
};
