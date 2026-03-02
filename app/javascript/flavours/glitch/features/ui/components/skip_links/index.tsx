import { useCallback, useId } from 'react';

import { useIntl } from 'react-intl';

import { useAppSelector } from 'flavours/glitch/store';

import classes from './skip_links.module.scss';

export const getNavigationSkipLinkId = () => 'skip-link-target-nav';
export const getColumnSkipLinkId = (index: number) =>
  `skip-link-target-content-${index}`;

export const SkipLinks: React.FC<{
  multiColumn: boolean;
  onFocusGettingStartedColumn: () => void;
}> = ({ multiColumn, onFocusGettingStartedColumn }) => {
  const intl = useIntl();
  const columnCount = useAppSelector((state) => {
    const settings = state.settings as Immutable.Collection<string, unknown>;
    return (settings.get('columns') as Immutable.Map<number, unknown>).size;
  });

  const focusMultiColumnNavbar = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      onFocusGettingStartedColumn();
    },
    [onFocusGettingStartedColumn],
  );

  return (
    <ul className={classes.list}>
      <li className={classes.listItem}>
        <SkipLink target={getColumnSkipLinkId(1)} hotkey='1'>
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main content',
          })}
        </SkipLink>
      </li>
      <li className={classes.listItem}>
        <SkipLink
          target={multiColumn ? `/getting-started` : getNavigationSkipLinkId()}
          onRouterLinkClick={multiColumn ? focusMultiColumnNavbar : undefined}
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
  onRouterLinkClick?: React.MouseEventHandler;
  hotkey: string;
}> = ({ children, hotkey, target, onRouterLinkClick }) => {
  const intl = useIntl();
  const id = useId();
  return (
    <>
      <a href={`#${target}`} aria-describedby={id} onClick={onRouterLinkClick}>
        {children}
      </a>
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
