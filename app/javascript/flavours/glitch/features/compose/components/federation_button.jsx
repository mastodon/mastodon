import { useCallback, useState, useRef } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import Overlay from 'react-overlays/Overlay';

import ShareIcon from '@/material-icons/400-24px/share.svg?react';
import ShareOffIcon from '@/material-icons/400-24px/share_off.svg?react';
import { changeComposeAdvancedOption } from 'flavours/glitch/actions/compose';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import DropdownMenu from './dropdown_menu';

const messages = defineMessages({
  change_federation_settings: { id: 'compose.change_federation', defaultMessage: 'Change federation settings' },
  local_only_label: { id: 'federation.local_only.short', defaultMessage: 'Local-only' },
  local_only_meta: { id: 'federation.local_only.long', defaultMessage: 'Prevent this post from reaching other servers' },
  federated_label: { id: 'federation.federated.short', defaultMessage: 'Federated' },
  federated_meta: { id: 'federation.federated.long', defaultMessage: 'Allow this post to reach other servers' },
});

export const FederationButton = () => {
  const intl = useIntl();

  const do_not_federate = useAppSelector((state) => state.getIn(['compose', 'advanced_options', 'do_not_federate']));
  const dispatch = useAppDispatch();

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

  const handleChange = useCallback((value) => {
    dispatch(changeComposeAdvancedOption('do_not_federate', value === 'local-only'));
  }, [dispatch]);

  const handleOverlayEnter = useCallback((state) => {
    setPlacement(state.placement);
  }, [setPlacement]);

  const options = [
    { icon: 'link', iconComponent: ShareIcon, value: 'federated', text: intl.formatMessage(messages.federated_label), meta: intl.formatMessage(messages.federated_meta) },
    { icon: 'link-slash', iconComponent: ShareOffIcon, value: 'local-only', text: intl.formatMessage(messages.local_only_label), meta: intl.formatMessage(messages.local_only_meta) },
  ];

  return (
    <div ref={containerRef}>
      <IconButton
        icon={do_not_federate ? 'link-slash' : 'link'}
        onClick={handleToggle}
        iconComponent={do_not_federate ? ShareOffIcon : ShareIcon}
        title={intl.formatMessage(messages.change_federation_settings)}
        active={open}
        size={18}
        inverted
      />

      <Overlay show={open} offset={[5, 5]} placement={placement} flip target={containerRef} popperConfig={{ strategy: 'fixed', onFirstUpdate: handleOverlayEnter }}>
        {({ props, placement }) => (
          <div {...props}>
            <div className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}>
              <DropdownMenu
                items={options}
                value={do_not_federate ? 'local-only' : 'federated'}
                onClose={handleClose}
                onChange={handleChange}
              />
            </div>
          </div>
        )}
      </Overlay>
    </div>
  );
};
