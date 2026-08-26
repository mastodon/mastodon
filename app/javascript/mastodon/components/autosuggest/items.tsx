import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { useAppSelector } from '@/mastodon/store';

import { Avatar } from '../avatar';
import { DisplayName } from '../display_name';
import { Emoji } from '../emoji';

import type { Suggestion } from './types';

export const AutosuggestItem: React.FC<{ suggestion: Suggestion }> = ({
  suggestion,
}) => {
  if (suggestion.type === 'account') {
    return <AutosuggestAccount id={suggestion.id} />;
  } else if (suggestion.type === 'hashtag') {
    return <div>#{suggestion.name}</div>;
  } else {
    const colons = `:${suggestion.id}:`;
    return (
      <div>
        <Emoji code={suggestion.native ?? colons} />

        {colons}
      </div>
    );
  }
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
