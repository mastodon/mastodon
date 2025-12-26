import { useCallback } from 'react';
import type { FC } from 'react';

import { changeComposeVisibility } from '@/mastodon/actions/compose_typed';
import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import { useAppSelector, useAppDispatch } from '@/mastodon/store';

import PrivacyDropdown from './privacy_dropdown';

interface VisibilityButtonProps {
  disabled?: boolean;
}

export const VisibilityButton: FC<VisibilityButtonProps> = ({
  disabled = false,
}) => {
  const dispatch = useAppDispatch();

  const visibility = useAppSelector(
    (state) => state.compose.get('privacy') as StatusVisibility,
  );

  const handleChange = useCallback(
    (newVisibility: StatusVisibility) => {
      dispatch(changeComposeVisibility(newVisibility));
    },
    [dispatch],
  );

  return (
    <PrivacyDropdown
      value={visibility}
      onChange={handleChange}
      disabled={disabled}
    />
  );
};
