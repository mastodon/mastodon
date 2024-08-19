import type { PropsWithChildren } from 'react';
import { useCallback, useState, useRef } from 'react';

import classNames from 'classnames';

import type { Placement, State as PopperState } from '@popperjs/core';
import Overlay from 'react-overlays/Overlay';

import ArrowDropDownIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';
import type { SelectItem } from 'mastodon/components/dropdown_selector';
import { DropdownSelector } from 'mastodon/components/dropdown_selector';
import { Icon } from 'mastodon/components/icon';

interface DropdownProps {
  value: string;
  options: SelectItem[];
  disabled?: boolean;
  onChange: (value: string) => void;
  placement?: Placement;
}

const Dropdown: React.FC<DropdownProps> = ({
  value,
  options,
  disabled,
  onChange,
  placement: initialPlacement = 'bottom-end',
}) => {
  const activeElementRef = useRef<Element | null>(null);
  const containerRef = useRef(null);
  const [isOpen, setOpen] = useState<boolean>(false);
  const [placement, setPlacement] = useState<Placement>(initialPlacement);

  const handleToggle = useCallback(() => {
    if (
      isOpen &&
      activeElementRef.current &&
      activeElementRef.current instanceof HTMLElement
    ) {
      activeElementRef.current.focus({ preventScroll: true });
    }

    setOpen(!isOpen);
  }, [isOpen, setOpen]);

  const handleMouseDown = useCallback(() => {
    if (!isOpen) activeElementRef.current = document.activeElement;
  }, [isOpen]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      switch (e.key) {
        case ' ':
        case 'Enter':
          if (!isOpen) activeElementRef.current = document.activeElement;
          break;
      }
    },
    [isOpen],
  );

  const handleClose = useCallback(() => {
    if (
      isOpen &&
      activeElementRef.current &&
      activeElementRef.current instanceof HTMLElement
    )
      activeElementRef.current.focus({ preventScroll: true });
    setOpen(false);
  }, [isOpen]);

  const handleOverlayEnter = useCallback(
    (state: Partial<PopperState>) => {
      if (state.placement) setPlacement(state.placement);
    },
    [setPlacement],
  );

  const valueOption = options.find((item) => item.value === value);

  return (
    <div ref={containerRef}>
      <button
        type='button'
        onClick={handleToggle}
        onMouseDown={handleMouseDown}
        onKeyDown={handleKeyDown}
        disabled={disabled}
        className={classNames('dropdown-button', { active: isOpen })}
      >
        <span className='dropdown-button__label'>{valueOption?.text}</span>
        <Icon id='down' icon={ArrowDropDownIcon} />
      </button>

      <Overlay
        show={isOpen}
        offset={[5, 5]}
        placement={placement}
        flip
        target={containerRef}
        popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}
      >
        {({ props, placement }) => (
          <div {...props}>
            <div
              className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}
            >
              <DropdownSelector
                items={options}
                value={value}
                onClose={handleClose}
                onChange={onChange}
                classNamePrefix='privacy-dropdown'
              />
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};

interface Props {
  value: string;
  options: SelectItem[];
  disabled?: boolean;
  onChange: (value: string) => void;
}

export const SelectWithLabel: React.FC<PropsWithChildren<Props>> = ({
  value,
  options,
  disabled,
  children,
  onChange,
}) => {
  return (
    <label className='app-form__toggle'>
      <div className='app-form__toggle__label'>{children}</div>

      <div className='app-form__toggle__toggle'>
        <div>
          <Dropdown
            value={value}
            onChange={onChange}
            disabled={disabled}
            options={options}
          />
        </div>
      </div>
    </label>
  );
};
