import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef, useState } from 'react';

import classNames from 'classnames';

import { supportsPassiveEvents } from 'detect-passive-events';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import { Icon } from 'mastodon/components/icon';

const listenerOptions = supportsPassiveEvents ? { passive: true, capture: true } : true;

export const PrivacyDropdownMenu = ({ style, items, value, onClose, onChange }) => {
  const nodeRef = useRef(null);
  const focusedItemRef = useRef(null);
  const [currentValue, setCurrentValue] = useState(value);

  const handleDocumentClick = useCallback((e) => {
    if (nodeRef.current && !nodeRef.current.contains(e.target)) {
      onClose();
      e.stopPropagation();
    }
  }, [nodeRef, onClose]);

  const handleClick = useCallback((e) => {
    const value = e.currentTarget.getAttribute('data-index');

    e.preventDefault();

    onClose();
    onChange(value);
  }, [onClose, onChange]);

  const handleKeyDown = useCallback((e) => {
    const value = e.currentTarget.getAttribute('data-index');
    const index = items.findIndex(item => (item.value === value));

    let element = null;

    switch (e.key) {
    case 'Escape':
      onClose();
      break;
    case ' ':
    case 'Enter':
      handleClick(e);
      break;
    case 'ArrowDown':
      element = nodeRef.current.childNodes[index + 1] || nodeRef.current.firstChild;
      break;
    case 'ArrowUp':
      element = nodeRef.current.childNodes[index - 1] || nodeRef.current.lastChild;
      break;
    case 'Tab':
      if (e.shiftKey) {
        element = nodeRef.current.childNodes[index + 1] || nodeRef.current.firstChild;
      } else {
        element = nodeRef.current.childNodes[index - 1] || nodeRef.current.lastChild;
      }
      break;
    case 'Home':
      element = nodeRef.current.firstChild;
      break;
    case 'End':
      element = nodeRef.current.lastChild;
      break;
    }

    if (element) {
      element.focus();
      setCurrentValue(element.getAttribute('data-index'));
      e.preventDefault();
      e.stopPropagation();
    }
  }, [nodeRef, items, onClose, handleClick, setCurrentValue]);

  useEffect(() => {
    document.addEventListener('click', handleDocumentClick, { capture: true });
    document.addEventListener('touchend', handleDocumentClick, listenerOptions);
    focusedItemRef.current?.focus({ preventScroll: true });

    return () => {
      document.removeEventListener('click', handleDocumentClick, { capture: true });
      document.removeEventListener('touchend', handleDocumentClick, listenerOptions);
    };
  }, [handleDocumentClick]);

  return (
    <ul style={{ ...style }} role='listbox' ref={nodeRef}>
      {items.map(item => (
        <li
          role='option'
          tabIndex={0}
          key={item.value}
          data-index={item.value}
          onKeyDown={handleKeyDown}
          onClick={handleClick}
          className={classNames('privacy-dropdown__option', { active: item.value === currentValue })}
          aria-selected={item.value === currentValue}
          ref={item.value === currentValue ? focusedItemRef : null}
        >
          <div className='privacy-dropdown__option__icon'>
            <Icon id={item.icon} icon={item.iconComponent} />
          </div>

          <div className='privacy-dropdown__option__content'>
            <strong>{item.text}</strong>
            {item.meta}
          </div>

          {item.extra && (
            <div className='privacy-dropdown__option__additional' title={item.extra}>
              <Icon id='info-circle' icon={InfoIcon} />
            </div>
          )}
        </li>
      ))}
    </ul>
  );
};

PrivacyDropdownMenu.propTypes = {
  style: PropTypes.object,
  items: PropTypes.array.isRequired,
  value: PropTypes.string.isRequired,
  onClose: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
};
