import type React from 'react';

import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { useAppSelector } from '@/mastodon/store';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { Emoji } from '../emoji';

import type {
  EmojiSuggestion,
  HashtagSuggestion,
  LocalHashtagSuggestion,
  Suggestion,
} from './types';

export const AutosuggestItem: React.FC<{ suggestion: Suggestion }> = ({
  suggestion,
}) => {
  if (suggestion.type === 'account') {
    return <AutosuggestAccount {...suggestion} />;
  } else if (suggestion.type === 'hashtag') {
    return <AutosuggestHashtag {...suggestion} />;
  }
  return <AutosuggestEmoji {...suggestion} />;
};

const AutosuggestAccount: React.FC<{ id: string }> = ({ id }) => {
  const account = useAppSelector((state) => selectPlainAccount(state, id));

  if (!account) {
    return null;
  }

  return (
    <div>
      <Avatar account={account} />
      <DisplayName account={account} />
    </div>
  );
};

const AutosuggestEmoji: React.FC<EmojiSuggestion> = ({ id, native }) => {
  const colons = `:${id}:`;
  return (
    <div>
      <Emoji code={native ?? colons} />

      {colons}
    </div>
  );
};

const AutosuggestHashtag: React.FC<
  HashtagSuggestion | LocalHashtagSuggestion
> = ({ name }) => {
  return <div>#{name}</div>;
};
