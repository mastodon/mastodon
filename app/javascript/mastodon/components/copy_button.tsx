import { useState, useCallback } from 'react';

import { defineMessages } from 'react-intl';

import { CopyIcon } from '@phosphor-icons/react';
import type { DistributedOmit } from 'type-fest';

import { showAlert } from '@/mastodon/actions/alerts';
import type {
  ButtonProps,
  IconButtonProps,
} from '@/mastodon/components/button';
import { Button, IconButton } from '@/mastodon/components/button';
import { useAppDispatch } from '@/mastodon/store';

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
  DistributedOmit<ButtonProps, 'onClick' | 'children'> & {
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
