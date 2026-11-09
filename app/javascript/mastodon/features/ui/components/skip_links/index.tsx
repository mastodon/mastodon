import { useId } from 'react';

import { useIntl } from 'react-intl';

import classes from './skip_links.module.scss';

export const getNavigationSkipLinkId = () => 'skip-link-target-nav';
export const getColumnSkipLinkId = (index: number | null) =>
  `skip-link-target-content-${index ?? ''}`;

export const SkipLinks: React.FC = () => {
  const intl = useIntl();

  return (
    <div className={classes.list}>
      <div className={classes.listItem}>
        <SkipLink target={getColumnSkipLinkId(1)} hotkey='2'>
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main content',
          })}
        </SkipLink>
      </div>
    </div>
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
