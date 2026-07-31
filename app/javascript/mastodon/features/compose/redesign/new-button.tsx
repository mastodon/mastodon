import { useState } from 'react';

import { FormattedMessage } from 'react-intl';

import {
  ChatCircleIcon,
  NewspaperIcon,
  PenNibIcon,
} from '@phosphor-icons/react';

import { IconButton } from '@/mastodon/components/button/redesign';
import {
  DropdownItemButton,
  DropdownPopover,
} from '@/mastodon/components/dropdown/redesign';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

export const ComposeRedesignButton: React.FC = () => {
  const [ref, setRef] = useState<HTMLButtonElement | null>(null);
  const [open, { onFalse, onToggle }] = useToggle();

  if (!isRedesignEnabled()) {
    return null;
  }

  return (
    <>
      <IconButton
        icon={PenNibIcon}
        color='neutral'
        ref={setRef}
        onClick={onToggle}
        style={{ position: 'fixed', right: '1rem', bottom: '1rem' }}
        size='lg'
      >
        <FormattedMessage
          id='compose.new'
          defaultMessage='Write a new post or messsage'
        />
      </IconButton>

      <DropdownPopover
        isOpen={open}
        maxWidth={180}
        reference={ref}
        onClose={onFalse}
        placement='top-end'
      >
        <DropdownItemButton leadingIcon={NewspaperIcon}>
          <FormattedMessage id='compose.new.post' defaultMessage='Post' />
        </DropdownItemButton>
        <DropdownItemButton leadingIcon={ChatCircleIcon}>
          <FormattedMessage id='compose.new.message' defaultMessage='Message' />
        </DropdownItemButton>
      </DropdownPopover>
    </>
  );
};
