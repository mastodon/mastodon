import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react';

import type { UniqueIdentifier } from '@dnd-kit/core';
import { useSortable } from '@dnd-kit/sortable';

import { normalizeKey } from '../hotkeys/utils';

interface UseSortableListArgs<Id extends UniqueIdentifier = string> {
  ids: Id[];
  onSort: (ids: Id[]) => void;
  onCancel: () => void;
}

export function useSortableList<Id extends UniqueIdentifier = string>({
  onCancel,
}: UseSortableListArgs<Id>) {
  const [isDragging, setIsDragging] = useState(false);

  const onDragStart = useCallback(() => {
    setIsDragging(true);
  }, []);

  const onDragEnd = useCallback(() => {
    setIsDragging(false);
  }, []);

  // Combines the Escape shortcut for closing the modal and for cancelling the drag, depending on the current state.
  const onModalExit: React.KeyboardEventHandler = useCallback(
    (event) => {
      const key = normalizeKey(event.key);

      if (key === 'escape') {
        // Stops propagation to avoid triggering the handler in ModalRoot.
        event.stopPropagation();

        // Trigger the drag cancel here, since onDragCancel triggers before this handler.
        if (isDragging) {
          setIsDragging(false);
        } else {
          onCancel();
        }
      }
    },
    [isDragging, onCancel],
  );

  return {
    isDragging,
    onDragStart,
    onDragEnd,
    onCancel,
    onModalExit,
  };
}

export const ItemHandleContext = createContext<{
  registerHandle: () => void;
  id: UniqueIdentifier;
}>({
  registerHandle: () => {
    // Empty
  },
  id: '',
});

export function useSortableHandle() {
  const { registerHandle, id } = useContext(ItemHandleContext);
  useEffect(() => {
    registerHandle();
  }, [registerHandle]);

  const { listeners, attributes, isDragging } = useSortable({ id });
  return {
    isDragging,
    listeners,
    attributes,
  };
}
