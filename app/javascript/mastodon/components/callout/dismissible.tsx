import { useCallback } from 'react';
import type { FC } from 'react';

import { useDismissible } from '@/mastodon/hooks/useDismissible';

import { Callout } from '.';
import type { CalloutProps } from '.';

type DismissibleCalloutProps = CalloutProps & {
  id: string;
};

export const DismissibleCallout: FC<DismissibleCalloutProps> = (props) => {
  const { dismiss, wasDismissed } = useDismissible(props.id);

  const { onClose } = props;
  const handleClose = useCallback(() => {
    dismiss();
    onClose?.();
  }, [dismiss, onClose]);

  if (wasDismissed) {
    return null;
  }

  return <Callout {...props} onClose={handleClose} />;
};
