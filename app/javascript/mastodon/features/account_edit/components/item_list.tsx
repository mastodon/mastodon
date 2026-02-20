import { useCallback } from 'react';

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
  disabled?: boolean;
}

export const AccountEditItemList = <Item extends AnyItem>({
  renderItem,
  items,
  onEdit,
  onDelete,
  disabled,
}: AccountEditItemListProps<Item>) => {
  if (items.length === 0) {
    return null;
  }

  return (
    <ul className={classes.itemList}>
      {items.map((item) => (
        <li key={item.id}>
          <span>{renderItem?.(item) ?? item.name}</span>
          <AccountEditItemButtons
            item={item}
            onEdit={onEdit}
            onDelete={onDelete}
            disabled={disabled}
          />
        </li>
      ))}
    </ul>
  );
};

type AccountEditItemButtonsProps<Item extends AnyItem = AnyItem> = Pick<
  AccountEditItemListProps<Item>,
  'onEdit' | 'onDelete' | 'disabled'
> & { item: Item };

const AccountEditItemButtons = <Item extends AnyItem>({
  item,
  onDelete,
  onEdit,
  disabled,
}: AccountEditItemButtonsProps<Item>) => {
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
      {onEdit && (
        <EditButton
          edit
          item={item.name}
          disabled={disabled}
          onClick={handleEdit}
        />
      )}
      {onDelete && (
        <DeleteIconButton
          item={item.name}
          disabled={disabled}
          onClick={handleDelete}
        />
      )}
    </div>
  );
};
