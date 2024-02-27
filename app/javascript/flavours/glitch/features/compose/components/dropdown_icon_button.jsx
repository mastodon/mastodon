import PropTypes from 'prop-types';
import { useCallback, useState, useRef } from 'react';

import Overlay from 'react-overlays/Overlay';

import { IconButton } from 'flavours/glitch/components/icon_button';

import { PrivacyDropdownMenu } from './privacy_dropdown_menu';

export const DropdownIconButton = ({ value, disabled, icon, onChange, iconComponent, title, options }) => {
  const containerRef = useRef(null);

  const [activeElement, setActiveElement] = useState(null);
  const [open, setOpen] = useState(false);
  const [placement, setPlacement] = useState('bottom');

  const handleToggle = useCallback(() => {
    if (open && activeElement) {
      activeElement.focus({ preventScroll: true });
      setActiveElement(null);
    }

    setOpen(!open);
  }, [open, setOpen, activeElement, setActiveElement]);

  const handleClose = useCallback(() => {
    if (open && activeElement) {
      activeElement.focus({ preventScroll: true });
      setActiveElement(null);
    }

    setOpen(false);
  }, [open, setOpen, activeElement, setActiveElement]);

  const handleOverlayEnter = useCallback((state) => {
    setPlacement(state.placement);
  }, [setPlacement]);

  return (
    <div ref={containerRef}>
      <IconButton
        disabled={disabled}
        icon={icon}
        onClick={handleToggle}
        iconComponent={iconComponent}
        title={title}
        active={open}
        size={18}
        inverted
      />

      <Overlay show={open} offset={[5, 5]} placement={placement} flip target={containerRef} popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}>
        {({ props, placement }) => (
          <div {...props}>
            <div className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}>
              <PrivacyDropdownMenu
                items={options}
                value={value}
                onClose={handleClose}
                onChange={onChange}
              />
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};

DropdownIconButton.propTypes = {
  value: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  icon: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  iconComponent: PropTypes.func.isRequired,
  options: PropTypes.array.isRequired,
  title: PropTypes.string.isRequired,
};
