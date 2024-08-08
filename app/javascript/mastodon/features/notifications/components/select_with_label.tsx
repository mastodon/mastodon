import type { PropsWithChildren } from 'react';
import { useCallback, useState, useRef } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import type { Placement, State as PopperState } from '@popperjs/core';
import Overlay from 'react-overlays/Overlay';

import ArrowDropDownIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';
import { DropdownSelector } from 'mastodon/components/dropdown_selector';
import { Icon } from 'mastodon/components/icon';

const messages = defineMessages({
  accept: { id: 'notifications.policy.accept', defaultMessage: 'Accept' },
  accept_hint: {
    id: 'notifications.policy.accept_hint',
    defaultMessage: 'Show in notifications',
  },
  filter: { id: 'notifications.policy.filter', defaultMessage: 'Filter' },
  filter_hint: {
    id: 'notifications.policy.filter_hint',
    defaultMessage: 'Send to filtered notifications inbox',
  },
  drop: { id: 'notifications.policy.drop', defaultMessage: 'Ignore' },
  drop_hint: {
    id: 'notifications.policy.drop_hint',
    defaultMessage: 'Send to the void, never to be seen again',
  },
});

interface DropdownProps {
  value: string;
  disabled?: boolean;
  onChange: (value: string) => void;
  placement?: Placement;
}

const Dropdown: React.FC<DropdownProps> = ({
  disabled,
  value,
  onChange,
  placement: initialPlacement = 'bottom-end',
}) => {
  const intl = useIntl();
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

  const items = [
    {
      value: 'accept',
      text: intl.formatMessage(messages.accept),
      meta: intl.formatMessage(messages.accept_hint),
    },
    {
      value: 'filter',
      text: intl.formatMessage(messages.filter),
      meta: intl.formatMessage(messages.filter_hint),
    },
    {
      value: 'drop',
      text: intl.formatMessage(messages.drop),
      meta: intl.formatMessage(messages.drop_hint),
    },
  ];

  const valueOption = items.find((item) => item.value === value);

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
                items={items}
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
  disabled?: boolean;
  onChange: (value: string) => void;
}

export const SelectWithLabel: React.FC<PropsWithChildren<Props>> = ({
  value,
  disabled,
  children,
  onChange,
}) => {
  return (
    <label className='app-form__toggle'>
      <div className='app-form__toggle__label'>{children}</div>

      <div className='app-form__toggle__toggle'>
        <div>
          <Dropdown value={value} onChange={onChange} disabled={disabled} />
        </div>
      </div>
    </label>
  );
};
