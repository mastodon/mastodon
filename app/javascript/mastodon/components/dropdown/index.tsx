import { useCallback, useId, useMemo, useRef, useState } from 'react';
import type { ComponentPropsWithoutRef, FC } from 'react';

import { FormattedMessage } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import type { SelectItem } from '../dropdown_selector';
import { DropdownSelector } from '../dropdown_selector';

interface DropdownProps {
  title: string;
  disabled?: boolean;
  items: SelectItem[];
  onChange: (value: string) => void;
  current: string;
  emptyText?: MessageDescriptor;
  classPrefix: string;
}

export const Dropdown: FC<
  DropdownProps & Omit<ComponentPropsWithoutRef<'button'>, keyof DropdownProps>
> = ({
  title,
  disabled,
  items,
  current,
  onChange,
  classPrefix,
  className,
  ...buttonProps
}) => {
  const buttonRef = useRef<HTMLButtonElement>(null);
  const accessibilityId = useId();

  const [open, setOpen] = useState(false);
  const handleToggle = useCallback(() => {
    if (!disabled) {
      setOpen((prevOpen) => !prevOpen);
    }
  }, [disabled]);
  const handleClose = useCallback(() => {
    setOpen(false);
  }, []);
  const currentText = useMemo(
    () => items.find((i) => i.value === current)?.text,
    [current, items],
  );
  return (
    <>
      <button
        type='button'
        {...buttonProps}
        title={title}
        aria-expanded={open}
        aria-controls={accessibilityId}
        onClick={handleToggle}
        disabled={disabled}
        className={classNames(
          `${classPrefix}__button`,
          {
            active: open,
            disabled,
          },
          className,
        )}
        ref={buttonRef}
      >
        {currentText ?? (
          <FormattedMessage
            id='dropdown.empty'
            defaultMessage='Select an option'
          />
        )}
      </button>

      <Overlay
        show={open}
        offset={[0, 4]}
        placement='bottom-start'
        onHide={handleClose}
        flip
        target={buttonRef.current}
        popperConfig={{
          strategy: 'fixed',
        }}
      >
        {({ props, placement }) => (
          <div {...props} className={`${classPrefix}__overlay`}>
            <div
              className={classNames(
                'dropdown-animation',
                `${classPrefix}__dropdown`,
                placement,
              )}
              id={accessibilityId}
            >
              <DropdownSelector
                items={items}
                value={current}
                onClose={handleClose}
                onChange={onChange}
                classNamePrefix={classPrefix}
              />
            </div>
          </div>
        )}
      </Overlay>
    </>
  );
};
