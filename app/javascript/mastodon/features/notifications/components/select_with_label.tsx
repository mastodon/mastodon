import type { PropsWithChildren } from 'react';
import { useCallback, useState, useRef, useId } from 'react';

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
  'aria-labelledby': string;
  'aria-describedby'?: string;
  placement?: Placement;
}

const Dropdown: React.FC<DropdownProps> = ({
  value,
  options,
  disabled,
  onChange,
  'aria-labelledby': ariaLabelledBy,
  'aria-describedby': ariaDescribedBy,
  placement: initialPlacement = 'bottom-end',
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);
  const [isOpen, setOpen] = useState<boolean>(false);
  const [placement, setPlacement] = useState<Placement>(initialPlacement);
  const uniqueId = useId();
  const menuId = `${uniqueId}-menu`;
  const buttonLabelId = `${uniqueId}-button`;

  const handleClose = useCallback(() => {
    if (isOpen && buttonRef.current) {
      buttonRef.current.focus({ preventScroll: true });
    }
    setOpen(false);
  }, [isOpen]);

  const handleToggle = useCallback(() => {
    if (isOpen) {
      handleClose();
    } else {
      setOpen(true);
    }
  }, [isOpen, handleClose]);

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
        ref={buttonRef}
        onClick={handleToggle}
        disabled={disabled}
        aria-expanded={isOpen}
        aria-controls={menuId}
        aria-labelledby={`${ariaLabelledBy} ${buttonLabelId}`}
        aria-describedby={ariaDescribedBy}
        className={classNames('dropdown-button', { active: isOpen })}
      >
        <span id={buttonLabelId} className='dropdown-button__label'>
          {valueOption?.text}
        </span>
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
          <div {...props} id={menuId}>
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
  label: string | React.ReactElement;
  hint: string | React.ReactElement;
  disabled?: boolean;
  onChange: (value: string) => void;
}

export const SelectWithLabel: React.FC<PropsWithChildren<Props>> = ({
  value,
  options,
  label,
  hint,
  disabled,
  onChange,
}) => {
  const uniqueId = useId();
  const labelId = `${uniqueId}-label`;
  const descId = `${uniqueId}-desc`;

  return (
    // This label is only used for its click-forwarding behaviour,
    // accessible names are assigned manually
    // eslint-disable-next-line jsx-a11y/label-has-associated-control
    <label className='app-form__toggle'>
      <div className='app-form__toggle__label'>
        <strong id={labelId}>{label}</strong>
        <span className='hint' id={descId}>
          {hint}
        </span>
      </div>

      <div className='app-form__toggle__toggle'>
        <Dropdown
          value={value}
          onChange={onChange}
          disabled={disabled}
          aria-labelledby={labelId}
          aria-describedby={descId}
          options={options}
        />
      </div>
    </label>
  );
};
