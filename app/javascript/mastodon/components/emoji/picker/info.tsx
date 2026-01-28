import { useCallback } from 'react';
import type { FC } from 'react';

import { IconButton } from '@/mastodon/components/icon_button';
import type { AnyEmojiData } from '@/mastodon/features/emoji/types';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import StarFilledIcon from '@/material-icons/400-24px/star-fill.svg?react';
import StarIcon from '@/material-icons/400-24px/star.svg?react';

import { Emoji } from '..';

import { usePickerContext } from './constants';
import classes from './styles.module.css';
import { emojiToKey } from './utils';

interface PickerEmojiInfoProps {
  emoji: AnyEmojiData;
  onClose: () => void;
}

export const PickerEmojiInfo: FC<PickerEmojiInfoProps> = ({
  emoji,
  onClose,
}) => {
  const { onSelect, onFavourite, favourites } = usePickerContext();
  const emojiKey = emojiToKey(emoji, false);
  const handleSelect = useCallback(() => {
    onSelect(emojiKey);
  }, [emojiKey, onSelect]);
  const handleFavourite = useCallback(() => {
    onFavourite(emojiKey);
  }, [emojiKey, onFavourite]);

  const label = 'label' in emoji ? emoji.label : `:${emoji.shortcode}:`;
  const isFavourite = favourites.includes(emojiKey);
  return (
    <div className={classes.info}>
      <button
        type='button'
        onClick={handleSelect}
        className={classes.infoEmoji}
      >
        <Emoji
          code={'unicode' in emoji ? emoji.unicode : `:${emoji.shortcode}:`}
          key={emojiKey}
        />
      </button>
      <IconButton
        icon='star'
        iconComponent={isFavourite ? StarFilledIcon : StarIcon}
        onClick={handleFavourite}
        title={isFavourite ? 'Remove from favourites' : 'Add to favourites'}
      />
      <div className={classes.infoLabel}>
        <p>{label}</p>
      </div>
      <IconButton
        icon='close'
        iconComponent={CloseIcon}
        onClick={onClose}
        title='Close info'
      />
    </div>
  );
};
