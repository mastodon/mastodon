import { useCallback } from 'react';

import { useLinks } from 'mastodon/hooks/useLinks';

import { EmojiHTML } from '../features/emoji/emoji_html';
import { isFeatureEnabled } from '../initial_state';
import { useAppSelector } from '../store';

interface AccountBioProps {
  className: string;
  accountId: string;
  showDropdown?: boolean;
}

export const AccountBio: React.FC<AccountBioProps> = ({
  className,
  accountId,
  showDropdown = false,
}) => {
  const handleClick = useLinks(showDropdown);
  const handleNodeChange = useCallback(
    (node: HTMLDivElement | null) => {
      if (!showDropdown || !node || node.childNodes.length === 0) {
        return;
      }
      addDropdownToHashtags(node, accountId);
    },
    [showDropdown, accountId],
  );
  const note = useAppSelector((state) => {
    const account = state.accounts.get(accountId);
    if (!account) {
      return '';
    }
    return isFeatureEnabled('modern_emojis')
      ? account.note
      : account.note_emojified;
  });
  const extraEmojis = useAppSelector((state) => {
    const account = state.accounts.get(accountId);
    return account?.emojis;
  });

  if (note.length === 0) {
    return null;
  }

  return (
    <div
      className={`${className} translate`}
      onClickCapture={handleClick}
      ref={handleNodeChange}
    >
      <EmojiHTML htmlString={note} extraEmojis={extraEmojis} />
    </div>
  );
};

function addDropdownToHashtags(node: HTMLElement | null, accountId: string) {
  if (!node) {
    return;
  }
  for (const childNode of node.childNodes) {
    if (!(childNode instanceof HTMLElement)) {
      continue;
    }
    if (
      childNode instanceof HTMLAnchorElement &&
      (childNode.classList.contains('hashtag') ||
        childNode.innerText.startsWith('#')) &&
      !childNode.dataset.menuHashtag
    ) {
      childNode.dataset.menuHashtag = accountId;
    } else if (childNode.childNodes.length > 0) {
      addDropdownToHashtags(childNode, accountId);
    }
  }
}
