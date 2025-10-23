import { useCallback } from 'react';

import classNames from 'classnames';

import { useLinks } from 'mastodon/hooks/useLinks';

import { useAppSelector } from '../store';
import { isModernEmojiEnabled } from '../utils/environment';

import { EmojiHTML } from './emoji/html';
import { useElementHandledLink } from './status/handled_link';

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
      if (
        !showDropdown ||
        !node ||
        node.childNodes.length === 0 ||
        isModernEmojiEnabled()
      ) {
        return;
      }
      addDropdownToHashtags(node, accountId);
    },
    [showDropdown, accountId],
  );

  const htmlHandlers = useElementHandledLink({
    hashtagAccountId: showDropdown ? accountId : undefined,
  });

  const note = useAppSelector((state) => {
    const account = state.accounts.get(accountId);
    if (!account) {
      return '';
    }
    return account.note_emojified;
  });
  const extraEmojis = useAppSelector((state) => {
    const account = state.accounts.get(accountId);
    return account?.emojis;
  });

  if (note.length === 0) {
    return null;
  }

  return (
    <EmojiHTML
      htmlString={note}
      extraEmojis={extraEmojis}
      className={classNames(className, 'translate')}
      onClickCapture={handleClick}
      ref={handleNodeChange}
      {...htmlHandlers}
    />
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
