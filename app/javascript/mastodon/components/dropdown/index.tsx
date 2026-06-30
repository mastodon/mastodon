import { useCallback, useId, useMemo, useState } from 'react';
import type { ComponentPropsWithoutRef, FC } from 'react';

import { useIntl } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

import classNames from 'classnames';

import UnfoldMoreIcon from '@/material-icons/400-24px/unfold_more.svg?react';

import type { SelectItem } from '../dropdown_selector';
import { DropdownSelector } from '../dropdown_selector';
import { Icon } from '../icon';
import { Popover } from '../popover';

interface DropdownProps {
  disabled?: boolean;
  items: SelectItem[];
  onChange: (value: string) => void;
  current: string;
  labelId: string;
  descriptionId?: string;
  emptyText?: MessageDescriptor;
  classPrefix: string;
}

export const Dropdown: FC<
  DropdownProps & Omit<ComponentPropsWithoutRef<'button'>, keyof DropdownProps>
> = ({
  disabled,
  items,
  current,
  onChange,
  labelId,
  descriptionId,
  classPrefix,
  className,
  id,
  ...buttonProps
}) => {
  const intl = useIntl();
  const [buttonElement, setButtonElement] = useState<HTMLButtonElement | null>(
    null,
  );
  const uniqueId = useId();
  const buttonId = id ?? `${uniqueId}-button`;
  const listboxId = `${uniqueId}-listbox`;

  const [open, setOpen] = useState(false);

  const handleToggle = useCallback(() => {
    if (!disabled) {
      setOpen((prevOpen) => {
        buttonElement?.focus();
        return !prevOpen;
      });
    }
  }, [buttonElement, disabled]);

  const handleClose = useCallback(() => {
    setOpen(false);
    buttonElement?.focus();
  }, [buttonElement]);

  const currentText = useMemo(
    () =>
      items.find((i) => i.value === current)?.text ??
      intl.formatMessage({
        id: 'dropdown.empty',
        defaultMessage: 'Select an option',
      }),
    [current, intl, items],
  );

  return (
    <>
      <button
        type='button'
        {...buttonProps}
        id={buttonId}
        aria-labelledby={`${labelId} ${buttonId}`}
        aria-describedby={descriptionId}
        aria-expanded={open}
        aria-controls={listboxId}
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
        ref={setButtonElement}
      >
        {currentText}
        <Icon
          id='unfold-icon'
          icon={UnfoldMoreIcon}
          className={`${classPrefix}__icon`}
        />
      </button>

      <Popover
        matchReferenceWidth
        isOpen={open}
        placement='bottom-start'
        onClose={handleClose}
        reference={buttonElement}
      >
        {({ props, placement }) => (
          <div {...props} className={`${classPrefix}__overlay`}>
            <div
              className={classNames(
                'dropdown-animation',
                `${classPrefix}__dropdown`,
                placement,
              )}
              id={listboxId}
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
      </Popover>
    </>
  );
};
