import { FormattedMessage } from 'react-intl';

import ElephantImage from '@/images/elephant_ui.svg?react';

import classes from './empty_state.module.scss';

const images = {
  default: <ElephantImage className={classes.defaultImage} />,
};

/**
 * Simple empty state component with a neutral default title and customisable message.
 *
 * Action buttons can be passed as `children`.
 */

export const EmptyState: React.FC<{
  image?: keyof typeof images | React.ReactElement | null;
  title?: React.ReactNode;
  message?: React.ReactNode;
  children?: React.ReactNode;
}> = ({
  image = 'default',
  title = (
    <FormattedMessage id='empty_state.no_results' defaultMessage='No results' />
  ),
  message,
  children,
}) => {
  const imageToRender = typeof image === 'string' ? images[image] : image;

  return (
    <div className={classes.wrapper}>
      {(title || message || imageToRender) && (
        <div className={classes.content}>
          {imageToRender}
          {!!title && <h3>{title}</h3>}
          {!!message && <p>{message}</p>}
        </div>
      )}

      {children}
    </div>
  );
};
