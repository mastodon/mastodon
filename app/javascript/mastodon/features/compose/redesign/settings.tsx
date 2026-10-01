import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { EyeSlashIcon, GearIcon, WarningIcon } from '@phosphor-icons/react';

import {
  changeComposeSensitivity,
  changeComposeSpoilerness,
} from '@/mastodon/actions/compose';
import { setComposeQuotePolicy } from '@/mastodon/actions/compose_typed';
import type { ApiQuotePolicy } from '@/mastodon/api_types/quotes';
import { IconButton } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuItemCheckbox,
  MenuItemDivider,
  MenuItemGroup,
  MenuItemRadio,
  MenuList,
  MenuTrigger,
} from '@/mastodon/components/menu';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { selectComposeSensitive } from './selectors';

export const ComposeSettingsMenu: React.FC = () => {
  return (
    <Menu>
      <MenuTrigger as={IconButton} icon={GearIcon} size='sm'>
        <FormattedMessage id='compose.settings' defaultMessage='Settings' />
      </MenuTrigger>

      <MenuList maxWidth={280} placement='top-end'>
        <ComposeSettingsInnerMenu />
      </MenuList>
    </Menu>
  );
};

const ComposeSettingsInnerMenu: React.FC = () => {
  // Quote policy
  const currentQuotePolicy = useAppSelector(
    (state) => state.compose.get('quote_policy') as ApiQuotePolicy | undefined,
  );
  const defaultQuotePolicy = useAppSelector(
    (state) => state.compose.get('default_quote_policy') as ApiQuotePolicy,
  );
  const quotePolicy = currentQuotePolicy ?? defaultQuotePolicy;

  const dispatch = useAppDispatch();
  const handleQuotePolicyChange = useCallback(
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

  // Sensitive content
  const { sensitive, mediaSensitive } = useAppSelector(selectComposeSensitive);

  const onSensitiveChange = useCallback(() => {
    dispatch(changeComposeSpoilerness());
  }, [dispatch]);
  const onMediaSensitiveChange = useCallback(() => {
    dispatch(changeComposeSensitivity());
  }, [dispatch]);

  return (
    <>
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
            id='visibility_modal.quote_public'
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

        <MenuItemRadio
          name='quote_policy'
          value='nobody'
          checked={quotePolicy === 'nobody'}
          onChange={handleQuotePolicyChange}
          keepMenuOpenOnClick
        >
          <FormattedMessage
            id='visibility_modal.quote_nobody'
            defaultMessage='Just me'
          />
        </MenuItemRadio>
      </MenuItemGroup>

      <MenuItemDivider />

      <MenuItemGroup
        label={
          <FormattedMessage
            id='compose.sensitive.label'
            defaultMessage='Sensitive content'
          />
        }
      >
        <MenuItemCheckbox
          name='content_warning'
          value='on'
          checked={sensitive}
          onChange={onSensitiveChange}
          keepMenuOpenOnClick
          icon={WarningIcon}
        >
          <FormattedMessage
            id='compose_form.spoiler.unmarked'
            defaultMessage='Add content warning'
          />
        </MenuItemCheckbox>
        <MenuItemCheckbox
          name='media_spoiler'
          value='on'
          checked={mediaSensitive}
          onChange={onMediaSensitiveChange}
          keepMenuOpenOnClick
          icon={EyeSlashIcon}
        >
          <FormattedMessage
            id='compose.blur_media'
            defaultMessage='Blur media only'
          />
        </MenuItemCheckbox>
      </MenuItemGroup>
    </>
  );
};
