import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { XIcon } from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button';
import type { CollectionLockupProps } from '@/mastodon/features/collections/components/collection_lockup';
import { CollectionLockup } from '@/mastodon/features/collections/components/collection_lockup';

import classes from './collection_preview_card.module.scss';

interface CollectionPreviewCardProps extends CollectionLockupProps {
  onRemove?: () => void;
}

export const CollectionPreviewCard: React.FC<CollectionPreviewCardProps> = ({
  collection,
  onRemove,
  ...otherProps
}) => {
  const removeButton = onRemove && (
    <IconButton
      icon={XIcon}
      onClick={onRemove}
      className={classes.removeButton}
    >
      <FormattedMessage id='tag.remove' defaultMessage='Remove' />
    </IconButton>
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
