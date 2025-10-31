import { useEffect, useRef, useState, useCallback, useMemo } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import { useLocation } from 'react-router-dom';

import Overlay from 'react-overlays/Overlay';
import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';

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
  hashtag?: string;
  accountId?: string;
}

export const HashtagMenuController: React.FC = () => {
  const intl = useIntl();
  const { signedIn } = useIdentity();
  const [open, setOpen] = useState(false);
  const [{ accountId, hashtag }, setTargetParams] = useState<TargetParams>({});
  const targetRef = useRef<HTMLAnchorElement | null>(null);
  const location = useLocation();
  const account = useAppSelector((state) =>
    accountId ? state.accounts.get(accountId) : undefined,
  );

  useEffect(() => {
    setOpen(false);
    targetRef.current = null;
  }, [setOpen, location]);

  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      const target = (e.target as HTMLElement).closest('a');

      if (e.button !== 0 || e.ctrlKey || e.metaKey) {
        return;
      }

      if (!isHashtagLink(target)) {
        return;
      }

      const hashtag = target.text.replace(/^#/, '');
      const accountId = target.getAttribute('data-menu-hashtag');

      if (!hashtag || !accountId) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();
      targetRef.current = target;
      setOpen(true);
      setTargetParams({ hashtag, accountId });
    };

    document.addEventListener('click', handleClick, { capture: true });

    return () => {
      document.removeEventListener('click', handleClick);
    };
  }, [setTargetParams, setOpen]);

  const handleClose = useCallback(() => {
    setOpen(false);
    targetRef.current = null;
  }, [setOpen]);

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
      target={targetRef}
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
