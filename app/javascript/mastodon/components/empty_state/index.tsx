import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ElephantImage from '@/images/elephant_ui.svg?react';

import { GIF } from '../gif';

import classes from './empty_state.module.scss';

const images = {
  default: <ElephantImage className={classes.defaultImage} />,
  error: (
    <GIF src='/oops.gif' staticSrc='/oops.png' className={classes.errorImage} />
  ),
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
  headingLevel?: 'h2' | 'h3' | 'h4';
  className?: string;
}> = ({
  image = 'default',
  title = (
    <FormattedMessage id='empty_state.no_results' defaultMessage='No results' />
  ),
  message,
  children,
  headingLevel: Heading = 'h2',
  className,
}) => {
  const imageToRender = typeof image === 'string' ? images[image] : image;

  return (
    <div className={classNames(classes.wrapper, className)}>
      {(title || message || imageToRender) && (
        <div className={classes.content}>
          {imageToRender}
          {!!title && <Heading className={classes.heading}>{title}</Heading>}
          {!!message && <p>{message}</p>}
        </div>
      )}

      {children}
    </div>
  );
};
