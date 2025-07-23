import { useCallback } from 'react';

import { useLinks } from 'mastodon/hooks/useLinks';

interface AccountBioProps {
  note: string;
  className: string;
  dropdownAccountId?: string;
}

export const AccountBio: React.FC<AccountBioProps> = ({
  note,
  className,
  dropdownAccountId,
}) => {
  const handleClick = useLinks(!!dropdownAccountId);
  const handleNodeChange = useCallback(
    (node: HTMLDivElement | null) => {
      if (!dropdownAccountId || !node || node.childNodes.length === 0) {
        return;
      }
      addDropdownToHashtags(node, dropdownAccountId);
    },
    [dropdownAccountId],
  );

  if (note.length === 0) {
    return null;
  }

  return (
    <div
      className={`${className} translate`}
      dangerouslySetInnerHTML={{ __html: note }}
      onClickCapture={handleClick}
      ref={handleNodeChange}
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
