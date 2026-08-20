import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react';

import type { DragStartEvent, UniqueIdentifier } from '@dnd-kit/core';
import { useSortable } from '@dnd-kit/sortable';

import { normalizeKey } from '../hotkeys/utils';

interface UseSortableListArgs {
  onCancel: () => void;
}

export function useSortableList({ onCancel }: UseSortableListArgs) {
  const [activeId, setActiveId] = useState<UniqueIdentifier | null>(null);

  const onDragStart = useCallback((event: DragStartEvent) => {
    setActiveId(event.active.id);
  }, []);

  const onDragEnd = useCallback(() => {
    setActiveId(null);
  }, []);

  // Combines the Escape shortcut for closing the modal and for cancelling the drag, depending on the current state.
  const onModalExit: React.KeyboardEventHandler = useCallback(
    (event) => {
      const key = normalizeKey(event.key);

      if (key === 'escape') {
        // Stops propagation to avoid triggering the handler in ModalRoot.
        event.stopPropagation();

        // Trigger the drag cancel here, since onDragCancel triggers before this handler.
        if (activeId) {
          setActiveId(null);
        } else {
          onCancel();
        }
      }
    },
    [activeId, onCancel],
  );

  return {
    activeId,
    onDragStart,
    onDragEnd,
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
