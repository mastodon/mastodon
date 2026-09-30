import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHashtag } from '@/mastodon/hooks/useHashtag';
import { useIdentity } from '@/mastodon/identity_context';

import { selectPlainAccount } from '../selectors/accounts';
import { useAppSelector } from '../store';

import {
  Menu,
  MenuItem,
  MenuItemDivider,
  MenuItemLink,
  MenuList,
} from './menu';

export const HashtagMenu: React.FC<{
  tagId: string;
  accountId?: string;
  children?: React.ReactNode;
}> = ({ tagId, accountId, children }) => {
  const [wasMenuOpened, setWasMenuOpened] = useState(false);
  const { tag, toggleFollow } = useHashtag(wasMenuOpened ? tagId : undefined);
  const account = useAppSelector((state) =>
    selectPlainAccount(state, accountId),
  );
  const { signedIn } = useIdentity();

  const handleMenuOpen = useCallback(() => {
    setWasMenuOpened(true);
  }, []);

  const tagName = tag?.name ?? tagId;
  const tagNameForUrl = tag ? encodeURIComponent(tag.name) : tagId;

  return (
    <Menu onOpen={handleMenuOpen}>
      {children}

      <MenuList container={undefined}>
        {signedIn && (
          <MenuItem onClick={toggleFollow} disabled={!tag}>
            {!tag ? (
              <FormattedMessage
                id='loading_indicator.label'
                defaultMessage='Loading…'
              />
            ) : tag.following ? (
              <FormattedMessage
                id='hashtag.unfollow'
                defaultMessage='Unfollow hashtag'
              />
            ) : (
              <FormattedMessage
                id='hashtag.follow'
                defaultMessage='Follow hashtag'
              />
            )}
          </MenuItem>
        )}
        <MenuItemLink to={`/tags/${tagNameForUrl}`}>
          <FormattedMessage
            id='hashtag.browse'
            defaultMessage='Browse posts in #{hashtag}'
            values={{ hashtag: tagName }}
          />
        </MenuItemLink>
        {!!account && (
          <MenuItemLink to={`/@${account.acct}/tagged/${tagNameForUrl}`}>
            <FormattedMessage
              id='hashtag.browse_from_account'
              defaultMessage='Browse posts from @{name} in #{hashtag}'
              values={{
                name: account.username,
                hashtag: tagName,
              }}
            />
          </MenuItemLink>
        )}
        {signedIn && (
          <>
            <MenuItemDivider />
            <MenuItemLink as='a' href='/filters' destructive>
              <FormattedMessage
                id='hashtag.mute'
                defaultMessage='Mute #{hashtag}'
                values={{ hashtag: tagName }}
              />
            </MenuItemLink>
          </>
        )}
      </MenuList>
    </Menu>
  );
};
