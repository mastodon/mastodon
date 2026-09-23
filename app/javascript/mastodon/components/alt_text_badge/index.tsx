import { useState, useCallback, useRef, useId } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import { useSelectableClick } from '@/mastodon/hooks/useSelectableClick';
import { isRedesignStatusEnabled } from '@/mastodon/utils/environment';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { Button } from '../button/redesign';
import { IconButton } from '../icon_button';
import { Popover } from '../popover';

import classes from './styles.module.scss';

export const AltTextBadge: React.FC<{
  description: string;
  className?: string;
}> = ({ description, className }) => {
  const intl = useIntl();
  const uniqueId = useId();
  const popoverId = `${uniqueId}-popover`;
  const titleId = `${uniqueId}-title`;
  const [buttonElement, setButtonElement] = useState<HTMLButtonElement | null>(
    null,
  );
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
    buttonElement?.focus();
  }, [buttonElement]);

  const [handleMouseDown, handleMouseUp] = useSelectableClick(handleClose);

  const ButtonComp = isRedesignStatusEnabled() ? Button : 'button';

  return (
    <>
      <ButtonComp
        size='xs'
        type='button'
        variant='solid'
        ref={setButtonElement}
        className={classNames('media-gallery__alt__label', className)}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={popoverId}
        aria-haspopup='dialog'
      >
        ALT
      </ButtonComp>

      <Popover
        isOpen={open}
        onClose={handleClose}
        reference={buttonElement}
        placement='top-end'
        offset={4}
      >
        {({ props }) => (
          <div {...props} className='hover-card-controller'>
            <div // eslint-disable-line jsx-a11y/no-noninteractive-element-interactions
              className={classNames(
                'info-tooltip',
                'dropdown-animation',
                isRedesignStatusEnabled() && classes.redesignPopover,
              )}
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
      </Popover>
    </>
  );
};
