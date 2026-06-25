import type { PropsWithChildren } from 'react';
import { useCallback, useState, useId } from 'react';

import classNames from 'classnames';

import { Popover } from '@/mastodon/components/popover';
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
}

const Dropdown: React.FC<DropdownProps> = ({
  value,
  options,
  disabled,
  onChange,
  'aria-labelledby': ariaLabelledBy,
  'aria-describedby': ariaDescribedBy,
}) => {
  const [buttonElement, setButtonElement] = useState<HTMLButtonElement | null>(
    null,
  );
  const [isOpen, setOpen] = useState<boolean>(false);
  const uniqueId = useId();
  const menuId = `${uniqueId}-menu`;
  const buttonLabelId = `${uniqueId}-button`;

  const handleClose = useCallback(() => {
    if (isOpen && buttonElement) {
      buttonElement.focus({ preventScroll: true });
    }
    setOpen(false);
  }, [isOpen, buttonElement]);

  const handleToggle = useCallback(() => {
    if (isOpen) {
      handleClose();
    } else {
      setOpen(true);
    }
  }, [isOpen, handleClose]);

  const valueOption = options.find((item) => item.value === value);

  return (
    <div>
      <button
        type='button'
        ref={setButtonElement}
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

      <Popover
        isOpen={isOpen}
        offset={5}
        placement='bottom-end'
        reference={buttonElement}
        onClose={handleClose}
      >
        {({ props, placement }) => (
          <div
            {...props}
            id={menuId}
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
        )}
      </Popover>
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
