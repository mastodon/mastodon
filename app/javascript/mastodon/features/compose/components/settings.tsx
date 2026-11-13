import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { GearIcon } from '@phosphor-icons/react';

import { setComposeQuotePolicy } from '@/mastodon/actions/compose_typed';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import { IconButton } from '@/mastodon/components/button';
import {
  Menu,
  MenuItemGroup,
  MenuItemRadio,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { selectComposePrivacy, selectComposeQuotePolicy } from './selectors';

export const ComposeSettingsMenu: React.FC = () => {
  const privacy = useAppSelector(selectComposePrivacy);

  if (privacy === 'direct') {
    return null;
  }

  return (
    <Menu>
      <MenuTrigger as={IconButton} icon={GearIcon} size='sm'>
        <FormattedMessage id='compose.settings' defaultMessage='Settings' />
      </MenuTrigger>

      <MenuList maxWidth={310} placement='top-end' strategy='fixed'>
        <ComposeSettingsInnerMenu />
      </MenuList>
    </Menu>
  );
};

const ComposeSettingsInnerMenu: React.FC = () => {
  // Quote policy
  const quotePolicy = useAppSelector(selectComposeQuotePolicy);
  const privacy = useAppSelector(selectComposePrivacy);
  const disablePublicQuotes = privacy === 'private';

  const dispatch = useAppDispatch();
  const onQuotePolicyChange = useCallback(
    ({ value }: { value: string }) => {
      let newQuotePolicy: ApiQuotePolicy = 'nobody';
      switch (value) {
        case 'public':
          newQuotePolicy = 'public';
          break;
        case 'followers':
          newQuotePolicy = 'followers';
          break;
      }
      dispatch(setComposeQuotePolicy(newQuotePolicy));
    },
    [dispatch],
  );

  return (
    <MenuItemGroup
      label={
        <FormattedMessage
          id='compose.visibility.quote_policy'
          defaultMessage='Who can quote'
        />
      }
    >
      <MenuItemRadio
        name='quote_policy'
        value='public'
        checked={quotePolicy === 'public'}
        onChange={onQuotePolicyChange}
        disabled={disablePublicQuotes}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='visibility_modal.quote_public'
          defaultMessage='Anyone'
        />
      </MenuItemRadio>

      <MenuItemRadio
        name='quote_policy'
        value='followers'
        checked={quotePolicy === 'followers'}
        onChange={onQuotePolicyChange}
        disabled={disablePublicQuotes}
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='compose.visibility.quote_policy.followers'
          defaultMessage='Followers'
        />
      </MenuItemRadio>

      <MenuItemRadio
        name='quote_policy'
        value='nobody'
        checked={quotePolicy === 'nobody'}
        onChange={onQuotePolicyChange}
        description={
          disablePublicQuotes && (
            <FormattedMessage
              id='compose.visibility.quote_policy.only_me_hint'
              defaultMessage="When your post's visibility is set to Followers, it can only be quoted by you."
            />
          )
        }
        keepMenuOpenOnClick
      >
        <FormattedMessage
          id='visibility_modal.quote_nobody'
          defaultMessage='Just me'
        />
      </MenuItemRadio>
    </MenuItemGroup>
  );
};
