import { FormattedMessage } from 'react-intl';

import classes from './empty_state.module.scss';

/**
 * Simple empty state component with a neutral default title and customisable message.
 *
 * Action buttons can be passed as `children`
 */

export const EmptyState: React.FC<{
  image?: React.ReactNode;
  title?: React.ReactNode;
  message?: React.ReactNode;
  children?: React.ReactNode;
}> = ({
  image,
  title = (
    <FormattedMessage id='empty_state.no_results' defaultMessage='No results' />
  ),
  message,
  children,
}) => {
  return (
    <div className={classes.wrapper}>
      {(title || message || image) && (
        <div className={classes.content}>
          {image}
          {!!title && <h3>{title}</h3>}
          {!!message && <p>{message}</p>}
        </div>
      )}

      {children}
    </div>
  );
};
