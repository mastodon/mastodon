import type { PropsWithChildren } from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';

interface BaseProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'children'> {
  block?: boolean;
  secondary?: boolean;
}

interface PropsChildren extends PropsWithChildren<BaseProps> {
  text?: undefined;
}

interface PropsWithText extends BaseProps {
  text: JSX.Element | string;
  children?: undefined;
}

type Props = PropsWithText | PropsChildren;

export const Button: React.FC<Props> = ({
  type = 'button',
  onClick,
  disabled,
  block,
  secondary,
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
        'button--block': block,
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
