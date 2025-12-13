import { useState, useCallback } from 'react';

import { defineMessages } from 'react-intl';

import classNames from 'classnames';

import ContentCopyIcon from '@/material-icons/400-24px/content_copy.svg?react';
import { showAlert } from 'mastodon/actions/alerts';
import { IconButton } from 'mastodon/components/icon_button';
import { useAppDispatch } from 'mastodon/store';

const messages = defineMessages({
  copied: {
    id: 'copy_icon_button.copied',
    defaultMessage: 'Copied to clipboard',
  },
});

export const CopyIconButton: React.FC<{
  title: string;
  value: string;
  className: string;
}> = ({ title, value, className }) => {
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
      icon=''
      iconComponent={ContentCopyIcon}
    />
  );
};
