import type { PropsWithChildren, JSX } from 'react';
import { useCallback } from 'react';

import classNames from 'classnames';

import { LoadingIndicator } from 'mastodon/components/loading_indicator';

interface BaseProps extends Omit<
  React.ButtonHTMLAttributes<HTMLButtonElement>,
  'children'
> {
  block?: boolean;
  secondary?: boolean;
  plain?: boolean;
  compact?: boolean;
  dangerous?: boolean;
  loading?: boolean;
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
  plain,
  compact,
  dangerous,
  loading,
  className,
  title,
  text,
  children,
  ...props
}) => {
  const handleClick = useCallback<React.MouseEventHandler<HTMLButtonElement>>(
    (e) => {
      if (disabled || loading) {
        e.stopPropagation();
        e.preventDefault();
      } else if (onClick) {
        onClick(e);
      }
    },
    [disabled, loading, onClick],
  );

  const label = text ?? children;

  return (
    <button
      className={classNames('button', className, {
        'button-secondary': secondary,
        'button--plain': plain,
        'button--compact': compact,
        'button--block': block,
        'button--dangerous': dangerous,
        loading,
      })}
      // Disabled buttons can't have focus, so we don't really
      // disable the button during loading
      disabled={disabled && !loading}
      aria-disabled={loading}
      // If the loading prop is used, announce label changes
      aria-live={loading !== undefined ? 'polite' : undefined}
      onClick={handleClick}
      title={title}
      // eslint-disable-next-line react/button-has-type -- set correctly via TS
      type={type}
      {...props}
    >
      {loading ? (
        <>
          <span className='button__label-wrapper'>{label}</span>
          <LoadingIndicator role='none' />
        </>
      ) : (
        label
      )}
    </button>
  );
};
