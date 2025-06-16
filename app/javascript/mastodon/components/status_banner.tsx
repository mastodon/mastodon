import type { MouseEventHandler } from 'react';
import { useCallback, useRef, useId } from 'react';

import { FormattedMessage } from 'react-intl';

export enum BannerVariant {
  Warning = 'warning',
  Filter = 'filter',
}

export const StatusBanner: React.FC<{
  children: React.ReactNode;
  variant: BannerVariant;
  expanded?: boolean;
  onClick?: () => void;
}> = ({ children, variant, expanded, onClick }) => {
  const descriptionId = useId();

  const buttonRef = useRef<HTMLButtonElement>(null);
  const forwardClick = useCallback<MouseEventHandler>((e) => {
    if (
      buttonRef.current &&
      e.target !== buttonRef.current &&
      !buttonRef.current.contains(e.target as Node)
    ) {
      buttonRef.current.click();
      buttonRef.current.focus();
    }
  }, []);

  return (
    // Element clicks are passed on to button
    // eslint-disable-next-line jsx-a11y/click-events-have-key-events, jsx-a11y/no-static-element-interactions
    <div
      className={
        variant === BannerVariant.Warning
          ? 'content-warning'
          : 'content-warning content-warning--filter'
      }
      onClick={forwardClick}
    >
      <p id={descriptionId}>{children}</p>

      <button
        ref={buttonRef}
        className='link-button'
        onClick={onClick}
        aria-describedby={descriptionId}
      >
        {expanded ? (
          <FormattedMessage
            id='content_warning.hide'
            defaultMessage='Hide post'
          />
        ) : variant === BannerVariant.Warning ? (
          <FormattedMessage
            id='content_warning.show_more'
            defaultMessage='Show more'
          />
        ) : (
          <FormattedMessage
            id='content_warning.show'
            defaultMessage='Show anyway'
          />
        )}
      </button>
    </div>
  );
};
