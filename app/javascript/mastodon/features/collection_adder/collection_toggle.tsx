import { useId } from 'react';

import type { ApiCollectionJSON } from '@/mastodon/api_types/collections';
import { Toggle } from '@/mastodon/components/form_fields';
import {
  ListItemContent,
  ListItemWrapper,
} from '@/mastodon/components/list_item';
import {
  AvatarGrid,
  CollectionInfo,
} from 'mastodon/features/collections/components/collection_lockup';

import classes from './collection_toggle.module.scss';

export interface CollectionToggleProps {
  collection: ApiCollectionJSON;
  checked: boolean;
  disabled?: boolean;
  loading?: boolean;
  subtitle?: React.ReactNode;
  onChange: React.ChangeEventHandler<HTMLInputElement>;
}

export const CollectionToggle: React.FC<CollectionToggleProps> = ({
  collection,
  checked,
  disabled,
  subtitle,
  onChange,
}) => {
  const uniqueId = useId();
  const toggleId = `${uniqueId}-toggle`;
  const infoId = `${uniqueId}-info`;

  return (
    <ListItemWrapper
      className={classes.wrapper}
      icon={
        <AvatarGrid
          accountIds={collection.items.map((item) => item.account_id)}
          sensitive={collection.sensitive}
        />
      }
      sideContent={
        <Toggle
          id={toggleId}
          checked={checked}
          disabled={disabled}
          onChange={onChange}
          aria-describedby={infoId}
        />
      }
    >
      <ListItemContent
        as='label'
        htmlFor={toggleId}
        subtitle={
          subtitle ?? (
            <CollectionInfo
              collection={collection}
              withTimestamp={false}
              withAuthorHandle={false}
            />
          )
        }
      >
        {collection.name}
      </ListItemContent>
    </ListItemWrapper>
  );
};
