import { useCallback, useEffect, useRef, useState } from 'react';

import classNames from 'classnames';

import { supportsPassiveEvents } from 'detect-passive-events';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';

import type { IconProp } from './icon';
import { Icon } from './icon';

const listenerOptions = supportsPassiveEvents
  ? { passive: true, capture: true }
  : true;

export interface SelectItem {
  value: string;
  icon?: string;
  iconComponent?: IconProp;
  text: string;
  meta: string;
  extra?: string;
}

interface Props {
  value: string;
  classNamePrefix: string;
  style?: React.CSSProperties;
  items: SelectItem[];
  onChange: (value: string) => void;
  onClose: () => void;
}

export const DropdownSelector: React.FC<Props> = ({
  style,
  items,
  value,
  classNamePrefix = 'privacy-dropdown',
  onClose,
  onChange,
}) => {
  const nodeRef = useRef<HTMLUListElement>(null);
  const focusedItemRef = useRef<HTMLLIElement>(null);
  const [currentValue, setCurrentValue] = useState(value);

  const handleDocumentClick = useCallback(
    (e: MouseEvent | TouchEvent) => {
      if (
        nodeRef.current &&
        e.target instanceof Node &&
        !nodeRef.current.contains(e.target)
      ) {
        onClose();
        e.stopPropagation();
      }
    },
    [nodeRef, onClose],
  );

  const handleClick = useCallback(
    (
      e: React.MouseEvent<HTMLLIElement> | React.KeyboardEvent<HTMLLIElement>,
    ) => {
      const value = e.currentTarget.getAttribute('data-index');

      e.preventDefault();

      onClose();
      if (value) onChange(value);
    },
    [onClose, onChange],
  );

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent<HTMLLIElement>) => {
      const value = e.currentTarget.getAttribute('data-index');
      const index = items.findIndex((item) => item.value === value);

      let element: Element | null | undefined = null;

      switch (e.key) {
        case 'Escape':
          onClose();
          break;
        case ' ':
        case 'Enter':
          handleClick(e);
          break;
        case 'ArrowDown':
          element =
            nodeRef.current?.children[index + 1] ??
            nodeRef.current?.firstElementChild;
          break;
        case 'ArrowUp':
          element =
            nodeRef.current?.children[index - 1] ??
            nodeRef.current?.lastElementChild;
          break;
        case 'Tab':
          if (e.shiftKey) {
            element =
              nodeRef.current?.children[index + 1] ??
              nodeRef.current?.firstElementChild;
          } else {
            element =
              nodeRef.current?.children[index - 1] ??
              nodeRef.current?.lastElementChild;
          }
          break;
        case 'Home':
          element = nodeRef.current?.firstElementChild;
          break;
        case 'End':
          element = nodeRef.current?.lastElementChild;
          break;
      }

      if (element && element instanceof HTMLElement) {
        const selectedValue = element.getAttribute('data-index');
        element.focus();
        if (selectedValue) setCurrentValue(selectedValue);
        e.preventDefault();
        e.stopPropagation();
      }
    },
    [nodeRef, items, onClose, handleClick, setCurrentValue],
  );

  useEffect(() => {
    document.addEventListener('click', handleDocumentClick, { capture: true });
    document.addEventListener('touchend', handleDocumentClick, listenerOptions);
    focusedItemRef.current?.focus({ preventScroll: true });

    return () => {
      document.removeEventListener('click', handleDocumentClick, {
        capture: true,
      });
      document.removeEventListener(
        'touchend',
        handleDocumentClick,
        listenerOptions,
      );
    };
  }, [handleDocumentClick]);

  return (
    <ul style={style} role='listbox' ref={nodeRef}>
      {items.map((item) => (
        <li
          role='option'
          tabIndex={0}
          key={item.value}
          data-index={item.value}
          onKeyDown={handleKeyDown}
          onClick={handleClick}
          className={classNames(`${classNamePrefix}__option`, {
            active: item.value === currentValue,
          })}
          aria-selected={item.value === currentValue}
          ref={item.value === currentValue ? focusedItemRef : null}
        >
          {item.icon && item.iconComponent && (
            <div className={`${classNamePrefix}__option__icon`}>
              <Icon id={item.icon} icon={item.iconComponent} />
            </div>
          )}

          <div className={`${classNamePrefix}__option__content`}>
            <strong>{item.text}</strong>
            {item.meta}
          </div>

          {item.extra && (
            <div
              className={`${classNamePrefix}__option__additional`}
              title={item.extra}
            >
              <Icon id='info-circle' icon={InfoIcon} />
            </div>
          )}
        </li>
      ))}
    </ul>
  );
};
