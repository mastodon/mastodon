import { useCallback, useId } from 'react';

import { useIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import { useAppSelector } from 'mastodon/store';

import classes from './skip_links.module.scss';

export const SKIP_LINK_TARGETS = {
  CONTENT: 'skip-link-target-content',
  NAV: 'skip-link-target-nav',
} as const;

export const SkipLinks: React.FC<{ multiColumn: boolean }> = ({
  multiColumn,
}) => {
  const intl = useIntl();
  const columnCount = useAppSelector((state) => {
    const settings = state.settings as Immutable.Collection<string, unknown>;
    return (settings.get('columns') as Immutable.Map<number, unknown>).size;
  });

  const focusMultiColumnNavbar = useCallback(() => {
    // Using a timeout to allow for the nav panel to be displayed
    // before attempting to set focus on it
    setTimeout(() => {
      const navbarSkipTarget = document.querySelector<HTMLAnchorElement>(
        `#${SKIP_LINK_TARGETS.NAV}`,
      );
      navbarSkipTarget?.focus();
    }, 0);
  }, []);

  return (
    <ul className={classes.list}>
      <li className={classes.listItem}>
        <SkipLink target={SKIP_LINK_TARGETS.CONTENT} hotkey='1'>
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main content',
          })}
        </SkipLink>
      </li>
      <li className={classes.listItem}>
        <SkipLink
          target={multiColumn ? `/getting-started` : SKIP_LINK_TARGETS.NAV}
          isRouterLink={multiColumn}
          onRouterLinkClick={focusMultiColumnNavbar}
          hotkey={multiColumn ? `${columnCount}` : '2'}
        >
          {intl.formatMessage({
            id: 'skip_links.skip_to_navigation',
            defaultMessage: 'Skip to main navigation',
          })}
        </SkipLink>
      </li>
    </ul>
  );
};

const SkipLink: React.FC<{
  children: string;
  target: string;
  isRouterLink?: boolean;
  onRouterLinkClick?: () => void;
  hotkey: string;
}> = ({ children, hotkey, target, isRouterLink, onRouterLinkClick }) => {
  const intl = useIntl();
  const id = useId();
  return (
    <>
      {isRouterLink ? (
        <Link to={target} onClick={onRouterLinkClick} aria-describedby={id}>
          {children}
        </Link>
      ) : (
        <a href={`#${target}`} aria-describedby={id}>
          {children}
        </a>
      )}
      <span id={id} className={classes.hotkeyHint}>
        {intl.formatMessage(
          {
            id: 'skip_links.hotkey',
            defaultMessage: '<span>Hotkey</span> {hotkey}',
          },
          {
            hotkey,
            span: (text) => <span className='sr-only'>{text}</span>,
          },
        )}
      </span>
    </>
  );
};
