import { useState, useCallback, useId } from 'react';

import { FormattedMessage } from 'react-intl';

import { Popover } from './popover';

export const LearnMoreLink: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const accessibilityId = useId();
  const [open, setOpen] = useState(false);
  const [trigger, setTrigger] = useState<HTMLButtonElement | null>(null);

  const handleClick = useCallback(() => {
    setOpen(!open);
  }, [open, setOpen]);

  return (
    <>
      <button
        className='link-button'
        ref={setTrigger}
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

      <Popover
        isOpen={open}
        onClose={handleClick}
        offset={5}
        placement='bottom-end'
        reference={trigger}
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
      </Popover>
    </>
  );
};
