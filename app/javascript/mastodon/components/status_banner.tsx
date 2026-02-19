import type { MouseEventHandler } from 'react';
import { useCallback, useRef, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import { AnimateEmojiProvider } from './emoji/context';

export enum BannerVariant {
  Warning = 'warning',
  Filter = 'filter',
}

const stopPropagation: MouseEventHandler = (e) => {
  e.stopPropagation();
};

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
    <AnimateEmojiProvider
      className={
        variant === BannerVariant.Warning
          ? 'content-warning'
          : 'content-warning content-warning--filter'
      }
      onClick={forwardClick}
      onMouseUp={stopPropagation}
    >
      <p id={descriptionId}>{children}</p>

      <button
        ref={buttonRef}
        type='button'
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
    </AnimateEmojiProvider>
  );
};
