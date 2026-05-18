import { useIntl } from 'react-intl';

import classNames from 'classnames';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { IconButton } from 'mastodon/components/icon_button';
import type { CollectionLockupProps } from 'mastodon/features/collections/components/collection_lockup';
import { CollectionLockup } from 'mastodon/features/collections/components/collection_lockup';

import classes from './collection_preview_card.module.scss';

interface CollectionPreviewCardProps extends CollectionLockupProps {
  onRemove?: () => void;
}

export const CollectionPreviewCard: React.FC<CollectionPreviewCardProps> = ({
  collection,
  onRemove,
  ...otherProps
}) => {
  const intl = useIntl();
  const removeButton = onRemove && (
    <IconButton
      icon='remove'
      iconComponent={CloseIcon}
      onClick={onRemove}
      title={intl.formatMessage({
        id: 'tag.remove',
        defaultMessage: 'Remove',
      })}
      className={classes.removeButton}
    />
  );

  return (
    <CollectionLockup
      collection={collection}
      className={classNames(classes.wrapper, 'collection-preview')}
      sideContent={removeButton}
      {...otherProps}
    />
  );
};
