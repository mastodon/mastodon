import { useId } from 'react';

import { useIntl } from 'react-intl';

import classes from './skip_links.module.scss';

export const SKIP_LINK_TARGETS = {
  CONTENT: 'skip-link-target-content',
  NAV: 'skip-link-target-nav',
} as const;

export const SkipLinks: React.FC<{ multiColumn: boolean }> = ({
  multiColumn,
}) => {
  const intl = useIntl();
  const id = useId();
  const contentDescId = `${id}-content`;
  const navDescId = `${id}-nav`;
  return (
    <ul className={classes.list}>
      <li className={classes.listItem}>
        <a
          href={`#${SKIP_LINK_TARGETS.CONTENT}`}
          aria-describedby={contentDescId}
        >
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main content',
          })}
        </a>
        <span id={contentDescId} className={classes.hotkeyHint}>
          {intl.formatMessage(
            {
              id: 'skip_links.hotkey',
              defaultMessage: '<span>Hotkey</span> {hotkey}',
            },
            {
              hotkey: multiColumn ? '1-9' : '1',
              span: (text) => <span className='sr-only'>{text}</span>,
            },
          )}
        </span>
      </li>
      <li className={classes.listItem}>
        <a href={`#${SKIP_LINK_TARGETS.NAV}`} aria-describedby={navDescId}>
          {intl.formatMessage({
            id: 'skip_links.skip_to_navigation',
            defaultMessage: 'Skip to main navigation',
          })}
        </a>
        <span id={navDescId} className={classes.hotkeyHint}>
          {intl.formatMessage(
            {
              id: 'skip_links.hotkey',
              defaultMessage: '<span>Hotkey</span> {hotkey}',
            },
            {
              hotkey: multiColumn ? '9' : '2',
              span: (text) => <span className='sr-only'>{text}</span>,
            },
          )}
        </span>
      </li>
    </ul>
  );
};
