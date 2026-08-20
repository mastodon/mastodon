import type { FC } from 'react';

import { Emoji } from './emoji';

interface LegacyEmoji {
  id: string;
  custom?: boolean;
  native?: string;
  imageUrl?: string;
}

export const AutosuggestEmoji: FC<{ emoji: LegacyEmoji }> = ({ emoji }) => {
  const colons = `:${emoji.id}:`;
  return (
    <div className='autosuggest-emoji'>
      <Emoji code={emoji.native ?? colons} />
      <div className='autosuggest-emoji__name'>{colons}</div>
    </div>
  );
};
