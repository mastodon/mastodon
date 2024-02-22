import { useCallback, useState, useRef } from 'react';

import { useIntl, defineMessages } from 'react-intl';

import Overlay from 'react-overlays/Overlay';

import CodeIcon from '@/material-icons/400-24px/code.svg?react';
import DescriptionIcon from '@/material-icons/400-24px/description.svg?react';
import MarkdownIcon from '@/material-icons/400-24px/markdown.svg?react';
import { changeComposeContentType } from 'flavours/glitch/actions/compose';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { useAppSelector, useAppDispatch } from 'flavours/glitch/store';

import DropdownMenu from './dropdown_menu';

const messages = defineMessages({
  change_content_type: { id: 'compose.content-type.change', defaultMessage: 'Change advanced formatting options' },
  plain_text_label: { id: 'compose.content-type.plain', defaultMessage: 'Plain text' },
  plain_text_meta: { id: 'compose.content-type.plain_meta', defaultMessage: 'Write with no advanced formatting' },
  markdown_label: { id: 'compose.content-type.markdown', defaultMessage: 'Markdown' },
  markdown_meta: { id: 'compose.content-type.markdown_meta', defaultMessage: 'Format your posts using Markdown' },
  html_label: { id: 'compose.content-type.html', defaultMessage: 'HTML' },
  html_meta: { id: 'compose.content-type.html_meta', defaultMessage: 'Format your posts using HTML' },
});

export const ContentTypeButton = () => {
  const intl = useIntl();

  const showButton = useAppSelector((state) => state.getIn(['local_settings', 'show_content_type_choice']));
  const contentType = useAppSelector((state) => state.getIn(['compose', 'content_type']));
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
    dispatch(changeComposeContentType(value));
  }, [dispatch]);

  const handleOverlayEnter = useCallback((state) => {
    setPlacement(state.placement);
  }, [setPlacement]);

  if (!showButton) {
    return null;
  }

  const options = [
    { icon: 'file-text', iconComponent: DescriptionIcon, value: 'text/plain', text: intl.formatMessage(messages.plain_text_label), meta: intl.formatMessage(messages.plain_text_meta) },
    { icon: 'arrow-circle-down', iconComponent: MarkdownIcon, value: 'text/markdown', text: intl.formatMessage(messages.markdown_label), meta: intl.formatMessage(messages.markdown_meta) },
    { icon: 'code', iconComponent: CodeIcon,  value: 'text/html', text: intl.formatMessage(messages.html_label), meta: intl.formatMessage(messages.html_meta) },
  ];

  const icon = {
    'text/plain': 'file-text',
    'text/markdown': 'arrow-circle-down',
    'text/html': 'code',
  }[contentType];

  const iconComponent = {
    'text/plain': DescriptionIcon,
    'text/markdown': MarkdownIcon,
    'text/html': CodeIcon,
  }[contentType];

  return (
    <div ref={containerRef}>
      <IconButton
        icon={icon}
        onClick={handleToggle}
        iconComponent={iconComponent}
        title={intl.formatMessage(messages.change_content_type)}
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
                value={contentType}
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
