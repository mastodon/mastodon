import { useEffect, useState, useCallback, useMemo } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { useLocation } from 'react-router-dom';

import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';
import Overlay from 'react-overlays/Overlay';

import { DropdownMenu } from 'mastodon/components/dropdown_menu';
import { useIdentity } from 'mastodon/identity_context';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
import { useAppSelector } from 'mastodon/store';

const messages = defineMessages({
  browseHashtag: {
    id: 'hashtag.browse',
    defaultMessage: 'Browse posts in #{hashtag}',
  },
  browseHashtagFromAccount: {
    id: 'hashtag.browse_from_account',
    defaultMessage: 'Browse posts from @{name} in #{hashtag}',
  },
  muteHashtag: { id: 'hashtag.mute', defaultMessage: 'Mute #{hashtag}' },
});

const offset = [5, 5] as OffsetValue;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

const isHashtagLink = (
  element: HTMLAnchorElement | null,
): element is HTMLAnchorElement => {
  if (!element) {
    return false;
  }

  return element.matches('[data-menu-hashtag]');
};

interface TargetParams {
  element: HTMLAnchorElement | null;
  hashtag: string;
  accountId: string;
}

export const HashtagMenuController: React.FC = () => {
  const intl = useIntl();
  const { signedIn } = useIdentity();

  const [target, setTarget] = useState<TargetParams | null>(null);
  const { element = null, accountId, hashtag } = target ?? {};
  const open = !!element;

  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );

  const location = useLocation();
  const [previousLocation, setPreviousLocation] = useState(location);
  if (location !== previousLocation) {
    setPreviousLocation(location);
    setTarget(null);
  }

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      const targetElement = (e.target as HTMLElement).closest('a');

      if (e.button !== 0 || e.ctrlKey || e.metaKey) {
        return;
      }

      if (!isHashtagLink(targetElement)) {
        return;
      }

      const hashtag = targetElement.text.replace(/^#/, '');
      const accountId = targetElement.getAttribute('data-menu-hashtag');

      if (!hashtag || !accountId) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();
      setTarget({ element: targetElement, hashtag, accountId });
    };

    document.addEventListener('click', handleClick, { capture: true });

    return () => {
      document.removeEventListener('click', handleClick);
    };
  }, []);

  const handleClose = useCallback(() => {
    setTarget(null);
  }, []);

  const menu = useMemo(() => {
    const arr: MenuItem[] = [
      {
        text: intl.formatMessage(messages.browseHashtag, {
          hashtag,
        }),
        to: `/tags/${hashtag}`,
      },
      {
        text: intl.formatMessage(messages.browseHashtagFromAccount, {
          hashtag,
          name: account?.username,
        }),
        to: `/@${account?.acct}/tagged/${hashtag}`,
      },
    ];

    if (signedIn) {
      arr.push(null, {
        text: intl.formatMessage(messages.muteHashtag, {
          hashtag,
        }),
        href: '/filters',
        dangerous: true,
      });
    }

    return arr;
  }, [intl, hashtag, account, signedIn]);

  if (!open) {
    return null;
  }

  return (
    <Overlay
      show={open}
      offset={offset}
      placement='bottom'
      flip
      target={element}
      popperConfig={popperConfig}
    >
      {({ props, arrowProps, placement }) => (
        <div {...props}>
          <div className={`dropdown-animation dropdown-menu ${placement}`}>
            <div
              className={`dropdown-menu__arrow ${placement}`}
              {...arrowProps}
            />

            <DropdownMenu
              items={menu}
              onClose={handleClose}
              openedViaKeyboard={false}
            />
          </div>
        </div>
      )}
    </Overlay>
  );
};
