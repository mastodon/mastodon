import { useCallback } from 'react';

import classNames from 'classnames';

interface BaseProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  block?: boolean;
  secondary?: boolean;
  text?: JSX.Element;
}

interface PropsWithChildren extends BaseProps {
  text?: never;
}

interface PropsWithText extends BaseProps {
  text: JSX.Element;
  children: never;
}

type Props = PropsWithText | PropsWithChildren;

export const Button: React.FC<Props> = ({
  text,
  type = 'button',
  onClick,
  disabled,
  block,
  secondary,
  className,
  title,
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
