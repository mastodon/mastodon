import { useState, useCallback } from 'react';

import { defineMessages } from 'react-intl';

import classNames from 'classnames';

import ContentCopyIcon from '@/material-icons/400-24px/content_copy.svg?react';
import { showAlert } from 'flavours/glitch/actions/alerts';
import { IconButton } from 'flavours/glitch/components/icon_button';
import { useAppDispatch } from 'flavours/glitch/store';

const messages = defineMessages({
  copied: {
    id: 'copy_icon_button.copied',
    defaultMessage: 'Copied to clipboard',
  },
});

export const CopyIconButton: React.FC<{
  title: string;
  value: string;
  className?: string;
  'aria-describedby'?: string;
}> = ({ title, value, className, 'aria-describedby': ariaDescribedBy }) => {
  const [copied, setCopied] = useState(false);
  const dispatch = useAppDispatch();

  const handleClick = useCallback(() => {
    void navigator.clipboard.writeText(value);
    setCopied(true);
    dispatch(showAlert({ message: messages.copied }));
    setTimeout(() => {
      setCopied(false);
    }, 700);
  }, [setCopied, value, dispatch]);

  return (
    <IconButton
      className={classNames(className, copied ? 'copied' : 'copyable')}
      title={title}
      onClick={handleClick}
      icon='copy-icon'
      iconComponent={ContentCopyIcon}
      aria-describedby={ariaDescribedBy}
    />
  );
};
