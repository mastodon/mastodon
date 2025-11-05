import { useState, useRef, useCallback, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import Overlay from 'react-overlays/Overlay';

export const LearnMoreLink: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const accessibilityId = useId();
  const [open, setOpen] = useState(false);
  const triggerRef = useRef(null);

  const handleClick = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  return (
    <>
      <button
        className='link-button'
        ref={triggerRef}
        onClick={handleClick}
        aria-expanded={open}
        aria-controls={accessibilityId}
        type='button'
      >
        <FormattedMessage
          id='learn_more_link.learn_more'
          defaultMessage='Learn more'
        />
      </button>

      <Overlay
        show={open}
        rootClose
        onHide={handleClick}
        offset={[5, 5]}
        placement='bottom-end'
        target={triggerRef}
      >
        {({ props }) => (
          <div
            {...props}
            role='region'
            id={accessibilityId}
            className='account__domain-pill__popout learn-more__popout dropdown-animation'
          >
            <div className='learn-more__popout__content'>{children}</div>

            <div>
              <button
                className='link-button'
                onClick={handleClick}
                type='button'
              >
                <FormattedMessage
                  id='learn_more_link.got_it'
                  defaultMessage='Got it'
                />
              </button>
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
