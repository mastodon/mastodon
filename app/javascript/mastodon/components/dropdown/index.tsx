import { useCallback, useId, useRef, useState } from 'react';
import type { FC } from 'react';

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
  current: SelectItem;
  emptyText?: MessageDescriptor;
  classPrefix: string;
}

export const Dropdown: FC<DropdownProps> = ({
  title,
  disabled,
  items,
  current,
  onChange,
  classPrefix,
}) => {
  const buttonRef = useRef<HTMLButtonElement>(null);
  const accessibilityId = useId();

  const [open, setOpen] = useState(false);
  const handleToggle = useCallback(() => {
    setOpen((prevOpen) => !prevOpen);
  }, []);
  const handleClose = useCallback(() => {
    setOpen(false);
  }, []);
  return (
    <>
      <button
        type='button'
        title={title}
        aria-expanded={open}
        aria-controls={accessibilityId}
        onClick={handleToggle}
        disabled={disabled}
        className={classNames('dropdown-button', `${classPrefix}__button`, {
          active: open,
        })}
        ref={buttonRef}
      >
        {current.text}
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
                value={current.value}
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
