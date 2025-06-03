import type { PropsWithChildren, JSX } from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';

interface BaseProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
  block?: boolean;
  secondary?: boolean;
  compact?: boolean;
  dangerous?: boolean;
}

interface PropsChildren extends PropsWithChildren<BaseProps> {
  text?: undefined;
}

interface PropsWithText extends BaseProps {
  text: JSX.Element | string;
  children?: undefined;
}

type Props = PropsWithText | PropsChildren;

/**
 * Primary UI component for user interaction that doesn't result in navigation.
 */

export const Button: React.FC<Props> = ({
  type = 'button',
  onClick,
  disabled,
  block,
  secondary,
  compact,
  dangerous,
  className,
  title,
  text,
  children,
  ...props
}) => {
  const handleClick = useCallback<React.MouseEventHandler<HTMLButtonElement>>(
    (e) => {
      if (!disabled && onClick) {
        onClick(e);
      }
    },
    [disabled, onClick],
  );

  return (
    <button
      className={classNames('button', className, {
        'button-secondary': secondary,
        'button--compact': compact,
        'button--block': block,
        'button--dangerous': dangerous,
      })}
      disabled={disabled}
      onClick={handleClick}
      title={title}
      type={type}
      {...props}
    >
      {text ?? children}
    </button>
  );
};
