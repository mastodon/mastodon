import { useState, useCallback } from 'react';

import { defineMessages } from 'react-intl';

import classNames from 'classnames';

import { CopyIcon } from '@phosphor-icons/react';
import type { DistributedOmit } from 'type-fest';

import ContentCopyIcon from '@/material-icons/400-24px/content_copy.svg?react';
import { showAlert } from 'mastodon/actions/alerts';
import { IconButton as LegacyIconButton } from 'mastodon/components/icon_button';
import { useAppDispatch } from 'mastodon/store';

import { Button } from './button';
import type { IconButtonProps } from './button/redesign';
import { IconButton } from './button/redesign';

const messages = defineMessages({
  copied: {
    id: 'copy_icon_button.copied',
    defaultMessage: 'Copied to clipboard',
  },
});

export function useCopyToClipboard({ text }: { text: string }) {
  const [wasCopied, setWasCopied] = useState(false);
  const dispatch = useAppDispatch();

  const copyText = useCallback(() => {
    void navigator.clipboard.writeText(text);
    setWasCopied(true);
    dispatch(showAlert({ message: messages.copied }));
    setTimeout(() => {
      setWasCopied(false);
    }, 700);
  }, [setWasCopied, text, dispatch]);

  return { copyText, wasCopied };
}

export const CopyButton: React.FC<
  Omit<
    React.ComponentPropsWithoutRef<typeof Button>,
    'onClick' | 'text' | 'children'
  > & {
    value: string;
    children: React.ReactNode | ((wasCopied: boolean) => React.ReactNode);
  }
> = ({ value, children, ...otherProps }) => {
  const { copyText, wasCopied } = useCopyToClipboard({ text: value });

  const label = typeof children === 'function' ? children(wasCopied) : children;

  return (
    <Button {...otherProps} onClick={copyText}>
      {label}
    </Button>
  );
};

export const CopyIconButtonLegacy: React.FC<{
  title: string;
  value: string;
  className?: string;
  'aria-describedby'?: string;
}> = ({ title, value, className, 'aria-describedby': ariaDescribedBy }) => {
  const { copyText, wasCopied } = useCopyToClipboard({ text: value });

  return (
    <LegacyIconButton
      className={classNames(className, wasCopied ? 'copied' : 'copyable')}
      title={title}
      onClick={copyText}
      icon='copy-icon'
      iconComponent={ContentCopyIcon}
      aria-describedby={ariaDescribedBy}
    />
  );
};

export const CopyIconButton: React.FC<
  {
    title: string;
    value: string;
  } & DistributedOmit<IconButtonProps, 'icon' | 'children'>
> = ({ title, value, ...otherProps }) => {
  const { copyText, wasCopied } = useCopyToClipboard({ text: value });

  return (
    <IconButton
      {...otherProps}
      onClick={copyText}
      icon={CopyIcon}
      variant={wasCopied ? 'solid' : otherProps.variant}
    >
      {title}
    </IconButton>
  );
};
