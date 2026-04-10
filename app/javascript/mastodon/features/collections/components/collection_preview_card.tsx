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
  return (
    <div className={classes.wrapper}>
      <CollectionLockup collection={collection} {...otherProps} />
    </div>
  );
};
