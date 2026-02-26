import { useIntl } from 'react-intl';

import classes from './skip_links.module.scss';

export const SKIP_LINK_TARGETS = {
  CONTENT: 'skip-link-target-content',
  NAV: 'skip-link-target-nav',
} as const;

export const SkipLinks: React.FC = () => {
  const intl = useIntl();
  return (
    <ul className={classes.wrapper}>
      <li>
        <a href={`#${SKIP_LINK_TARGETS.CONTENT}`}>
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main content',
          })}
        </a>
      </li>
      <li>
        <a href={`#${SKIP_LINK_TARGETS.NAV}`}>
          {intl.formatMessage({
            id: 'skip_links.skip_to_content',
            defaultMessage: 'Skip to main navigation',
          })}
        </a>
      </li>
    </ul>
  );
};
