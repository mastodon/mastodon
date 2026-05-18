import { useState, useCallback, useRef, useId } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';
import Overlay from 'react-overlays/Overlay';

import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { useSelectableClick } from 'mastodon/hooks/useSelectableClick';

import { IconButton } from '../icon_button';

import classes from './styles.module.scss';

const offset = [0, 4] as OffsetValue;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

export const AltTextBadge: React.FC<{
  description: string;
  className?: string;
}> = ({ description, className }) => {
  const intl = useIntl();
  const uniqueId = useId();
  const popoverId = `${uniqueId}-popover`;
  const titleId = `${uniqueId}-title`;
  const buttonRef = useRef<HTMLButtonElement>(null);
  const popoverRef = useRef<HTMLDivElement>(null);
  const [open, setOpen] = useState(false);

  const handleClick = useCallback(() => {
    setOpen((v) => !v);
    setTimeout(() => {
      popoverRef.current?.focus();
    }, 0);
  }, [setOpen]);

  const handleClose = useCallback(() => {
    setOpen(false);
    buttonRef.current?.focus();
  }, [setOpen]);

  const [handleMouseDown, handleMouseUp] = useSelectableClick(handleClose);

  return (
    <>
      <button
        type='button'
        ref={buttonRef}
        className={classNames('media-gallery__alt__label', className)}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={popoverId}
        aria-haspopup='dialog'
      >
        ALT
      </button>

      <Overlay
        rootClose
        onHide={handleClose}
        show={open}
        target={buttonRef}
        placement='top-end'
        flip
        offset={offset}
        popperConfig={popperConfig}
      >
        {({ props }) => (
          <div {...props} className='hover-card-controller'>
            <div // eslint-disable-line jsx-a11y/no-noninteractive-element-interactions
              className='info-tooltip dropdown-animation'
              role='dialog'
              aria-labelledby={titleId}
              ref={popoverRef}
              id={popoverId}
              onMouseDown={handleMouseDown}
              onMouseUp={handleMouseUp}
              // eslint-disable-next-line jsx-a11y/no-noninteractive-tabindex
              tabIndex={0}
            >
              <h4 id={titleId}>
                <FormattedMessage
                  id='alt_text_badge.title'
                  defaultMessage='Alt text'
                />
              </h4>

              <IconButton
                title={intl.formatMessage({
                  id: 'lightbox.close',
                  defaultMessage: 'Close',
                })}
                icon='close'
                iconComponent={CloseIcon}
                onClick={handleClose}
                className={classes.closeButton}
              />

              <p>{description}</p>
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
