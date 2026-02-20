import type { ChangeEventHandler, FC } from 'react';
import { useRef, useCallback } from 'react';

import Overlay from 'react-overlays/esm/Overlay';

import { TextInput } from '@/mastodon/components/form_fields';
import {
  clearSearch,
  updateSearchQuery,
} from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

export const AccountEditTagSearch: FC = () => {
  const { query, isLoading, results } = useAppSelector(
    (state) => state.profileEdit.search,
  );

  const dispatch = useAppDispatch();
  const handleSearchChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (e) => {
      void dispatch(updateSearchQuery(e.target.value));
    },
    [dispatch],
  );

  const wrapperRef = useRef<HTMLDivElement>(null);
  const anchorRef = useRef<HTMLInputElement>(null);
  const handleClose = useCallback(() => {
    dispatch(clearSearch());
  }, [dispatch]);

  return (
    <div ref={wrapperRef}>
      <TextInput
        value={query}
        disabled={isLoading}
        onChange={handleSearchChange}
        ref={anchorRef}
      />
      <Overlay
        show={results !== undefined}
        onHide={handleClose}
        rootClose
        container={wrapperRef}
        target={anchorRef}
        placement='bottom-start'
      >
        {({ props }) => (
          <div {...props}>
            <ul>
              {results?.map((result) => (
                <li key={result.id}>{result.name}</li>
              ))}
            </ul>
          </div>
        )}
      </Overlay>
    </div>
  );
};
