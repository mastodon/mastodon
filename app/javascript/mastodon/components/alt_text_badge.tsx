import { useState, useCallback, useRef } from 'react';

import { FormattedMessage } from 'react-intl';

import Overlay from 'react-overlays/Overlay';
import type {
  OffsetValue,
  UsePopperOptions,
} from 'react-overlays/esm/usePopper';

const offset = [0, 4] as OffsetValue;
const popperConfig = { strategy: 'fixed' } as UsePopperOptions;

export const AltTextBadge: React.FC<{
  description: string;
}> = ({ description }) => {
  const anchorRef = useRef<HTMLButtonElement>(null);
  const [open, setOpen] = useState(false);

  const handleClick = useCallback(() => {
    setOpen((v) => !v);
  }, [setOpen]);

  const handleClose = useCallback(() => {
    setOpen(false);
  }, [setOpen]);

  return (
    <>
      <button
        ref={anchorRef}
        className='media-gallery__alt__label'
        onClick={handleClick}
      >
        ALT
      </button>

      <Overlay
        rootClose
        onHide={handleClose}
        show={open}
        target={anchorRef.current}
        placement='top-end'
        flip
        offset={offset}
        popperConfig={popperConfig}
      >
        {({ props }) => (
          <div {...props} className='hover-card-controller'>
            <div
              className='media-gallery__alt__popover dropdown-animation'
              role='tooltip'
            >
              <h4>
                <FormattedMessage
                  id='alt_text_badge.title'
                  defaultMessage='Alt text'
                />
              </h4>
              <p>{description}</p>
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
