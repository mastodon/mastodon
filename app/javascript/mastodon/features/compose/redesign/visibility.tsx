import type React from 'react';
import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  ChatCircleIcon,
  MagnifyingGlassIcon,
  NewspaperIcon,
  QuotesIcon,
} from '@phosphor-icons/react';

import {
  changeComposeVisibility,
  setComposeQuotePolicy,
} from '@/mastodon/actions/compose_typed';
import { openModal } from '@/mastodon/actions/modal';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { CaretIcon } from '@/mastodon/components/button/redesign';
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import {
  Menu,
  MenuList,
  MenuTrigger,
  MenuItemDivider,
  MenuItemGroup,
  MenuItem,
  MenuItemRadio,
  MenuItemCheckbox,
} from '@/mastodon/components/menu';
import { selectPlainAccount } from '@/mastodon/selectors/accounts';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { selectComposeMentions, selectComposePrivacy } from './selectors';

export const ComposeVisibility: React.FC<{ className?: string }> = ({
  className,
}) => {
  const privacy = useAppSelector(selectComposePrivacy);

  return (
    <div className={className}>
      <FormattedMessage
        id='compose.post.to'
        defaultMessage='To:'
        description='Before button that indicates who a post is for (Public, Followers, mentioned people)'
      />
      <Menu>
        <MenuTrigger size='sm' trailingIcon={CaretIcon}>
          <ComposeVisibilityButtonText privacy={privacy} />
        </MenuTrigger>

        {privacy !== 'direct' ? (
          <ComposeVisibilityMenu />
        ) : (
          <ComposeDirectMenu />
        )}
      </Menu>
    </div>
  );
};

const ComposeVisibilityButtonText: React.FC<{
  privacy: StatusVisibility;
}> = ({ privacy }) => {
  const mentions = useAppSelector(selectComposeMentions);
  const firstMentionedAccount = useAppSelector((state) =>
    selectPlainAccount(state, mentions.at(0)),
  );

  if (privacy === 'public' || privacy === 'unlisted') {
    return (
      <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
    );
  } else if (privacy === 'private') {
    return (
      <FormattedMessage
        id='compose.post.privacy.followers'
        defaultMessage='Followers {count, plural, =0 {} one {+ # other} other {+ # others}}'
        description='Count is # of other people mentioned in the post. If zero, just output "Followers".'
        values={{ count: mentions.length }}
      />
    );
  } else if (mentions.length > 0) {
    return (
      <FormattedMessage
        id='compose.message.direct.followers'
        defaultMessage='{name} {count, plural, =0 {} one {+ # other} other {+ # others}}'
        description='Name is the primary display name, count is # of other people mentioned in the post'
        values={{
          name: <DisplayNameSimple account={firstMentionedAccount} />,
          count: mentions.length - 1,
        }}
      />
    );
  }

  return '-';
};

const ComposeVisibilityMenu: React.FC = () => {
  const privacy = useAppSelector(selectComposePrivacy);
  const defaultPrivacy = useAppSelector(
    (state) => state.compose.get('default_privacy') as StatusVisibility,
  );
  const currentQuotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy | undefined,
  );
  const defaultQuotePolicy = useAppSelector(
    (state) => state.compose.get('default_quote_policy') as ApiQuotePolicy,
  );
  const quotePolicy = currentQuotePolicy ?? defaultQuotePolicy;

  const dispatch = useAppDispatch();
  const handlePrivacyChange = useCallback(
    ({ value }: { value: string }) => {
      if (value === 'private' && privacy !== 'private') {
        dispatch(changeComposeVisibility(value));
      } else if (value === 'public' && privacy === 'private') {
        dispatch(
          changeComposeVisibility(
            defaultPrivacy === 'unlisted' ? 'unlisted' : 'public',
          ),
        );
      } else if (value === 'unlisted' && privacy !== 'private') {
        dispatch(
          changeComposeVisibility(privacy === 'public' ? 'unlisted' : 'public'),
        );
      }
    },
    [defaultPrivacy, dispatch, privacy],
  );
  const handleQuotePolicyChange = useCallback(
    ({ value, checked }: { value: string; checked?: boolean }) => {
      let newQuotePolicy: ApiQuotePolicy = 'nobody';
      switch (value) {
        case 'public':
          newQuotePolicy = 'public';
          break;
        case 'followers':
          newQuotePolicy = 'followers';
          break;
        case 'others':
          // If it's not checked, then it's nobody.
          if (checked) {
            // Only use the default if it's not nobody, as then it'll never be enabled.
            newQuotePolicy =
              defaultQuotePolicy !== 'nobody' ? defaultQuotePolicy : 'public';
          }
          break;
      }
      dispatch(setComposeQuotePolicy(newQuotePolicy));
    },
    [defaultQuotePolicy, dispatch],
  );

  const handleSwitchToMessage: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(changeComposeVisibility('direct'));
    }, [dispatch]);

  return (
    <MenuList placement='bottom-start' offset={4} maxWidth={280}>
      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.visibility.title'
            defaultMessage='Visibility'
          />
        }
      >
        <MenuItemRadio
          name='visibility'
          value='public'
          checked={privacy === 'public' || privacy === 'unlisted'}
          onChange={handlePrivacyChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
        </MenuItemRadio>

        <MenuItemRadio
          name='visibility'
          value='private'
          checked={privacy === 'private'}
          onChange={handlePrivacyChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='privacy.private.short'
            defaultMessage='Followers'
          />
        </MenuItemRadio>

        <MenuItemDivider />

        <MenuItemCheckbox
          value='unlisted'
          disabled={privacy === 'private'}
          checked={privacy === 'public'}
          onChange={handlePrivacyChange}
          icon={MagnifyingGlassIcon}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='compose.discoverable'
            defaultMessage='Discoverable in public feeds & search results'
          />
        </MenuItemCheckbox>

        <MenuItemCheckbox
          value='others'
          disabled={privacy === 'private'}
          checked={quotePolicy !== 'nobody' && privacy !== 'private'}
          onChange={handleQuotePolicyChange}
          icon={QuotesIcon}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='compose.quotable'
            defaultMessage='Allow others to quote'
          />
        </MenuItemCheckbox>
      </MenuItemGroup>

      {quotePolicy !== 'nobody' && privacy !== 'private' && (
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
            onChange={handleQuotePolicyChange}
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='compose.visibility.quote_policy.anyone'
              defaultMessage='Anyone'
            />
          </MenuItemRadio>

          <MenuItemRadio
            name='quote_policy'
            value='followers'
            checked={quotePolicy === 'followers'}
            onChange={handleQuotePolicyChange}
            keepMenuOpenOnClick
          >
            <FormattedMessage
              id='compose.visibility.quote_policy.followers'
              defaultMessage='Followers'
            />
          </MenuItemRadio>
        </MenuItemGroup>
      )}

      <MenuItemDivider />

      <MenuItem icon={ChatCircleIcon} onClick={handleSwitchToMessage}>
        <FormattedMessage
          id='compose.post.to_message'
          defaultMessage='Compose a message instead'
          description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
        />
      </MenuItem>
    </MenuList>
  );
};

const ComposeDirectMenu: React.FC = () => {
  const dispatch = useAppDispatch();
  const handleSwitchToPost: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(() => {
      dispatch(
        openModal({ modalType: 'COMPOSER_SWITCH_TO_POST', modalProps: {} }),
      );
    }, [dispatch]);

  return (
    <MenuList placement='bottom-start' offset={4} maxWidth={280}>
      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.visibility.title'
            defaultMessage='Visibility'
          />
        }
      >
        <MenuItemRadio value='direct' disabled checked>
          <FormattedMessage
            id='compose.visibility.direct_note'
            defaultMessage='Everyone mentioned'
          />
        </MenuItemRadio>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItem icon={NewspaperIcon} onClick={handleSwitchToPost}>
        <FormattedMessage
          id='compose.visibility.to_post'
          defaultMessage='Compose a post instead'
        />
      </MenuItem>
    </MenuList>
  );
};
