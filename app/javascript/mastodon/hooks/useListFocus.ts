import { useCallback, useId, useMemo, useState } from 'react';

interface UseListFocusArgs {
  /** Array of IDs. */
  ids: string[];
  /** The initially selected ID. */
  initialId?: string;
  /** Callback for when an item is selected. */
  onSelectId?: (id: string) => void;
  /** Callback to determine if a given ID is disabled. */
  getIsIdDisabled?: (id: string) => boolean;
  /** Callback when an item is clicked on. */
  onClickId?: (id: string, event: React.MouseEvent) => void;
  /** Callback when an item is focused. */
  onFocusId?: (id: string, event: React.FocusEvent) => void;
  /** Callback when a key is pressed when an item is focused. */
  onKeyDownId?: (id: string, event: React.KeyboardEvent) => void;
  /** Callback when the mouse enters an item space. */
  onMouseEnterId?: (id: string, event: React.MouseEvent) => void;
}

type ItemComponentProps = {
  'data-id': string;
  'data-highlighted': boolean;
} & Required<
  Pick<
    React.HTMLAttributes<Element>,
    | 'tabIndex'
    | 'aria-disabled'
    | 'aria-selected'
    | 'onClick'
    | 'onFocus'
    | 'onKeyDown'
    | 'onMouseEnter'
  >
>;

export function useListFocus({
  ids,
  initialId: selectedInitialId,
  getIsIdDisabled,
  onMouseEnterId,
  onFocusId,
  onKeyDownId,
  onClickId,
  onSelectId,
}: UseListFocusArgs) {
  const baseId = useId(); // The baseId is a unique ID prefix to avoid needing a wrapper ref.
  const [selectedId, setSelectedId] = useState(selectedInitialId ?? null);

  const isDisabled = useCallback(
    (id: string) => {
      if (getIsIdDisabled) {
        return getIsIdDisabled(id);
      }
      const element = idToElement(id, baseId);
      if (element?.ariaDisabled) {
        return true;
      }
      return false;
    },
    [getIsIdDisabled, baseId],
  );

  // Calculate the initial ID as either the selected ID or the first non-disabled ID.
  const initialId = useMemo(() => {
    if (
      selectedInitialId &&
      ids.includes(selectedInitialId) &&
      !isDisabled(selectedInitialId)
    ) {
      return selectedInitialId;
    }
    return ids.find((id) => !isDisabled(id)) ?? null;
  }, [ids, isDisabled, selectedInitialId]);

  const [rawHighlightedId, setHighlightedId] = useState(initialId);

  // Get the valid highlighted ID.
  const highlightedId = useMemo(() => {
    if (
      rawHighlightedId !== null &&
      ids.includes(rawHighlightedId) &&
      !isDisabled(rawHighlightedId)
    ) {
      return rawHighlightedId;
    }
    return initialId;
  }, [ids, initialId, isDisabled, rawHighlightedId]);

  // Set the correct highlight, triggering focus on the element.
  const onHighlight = useCallback(
    (id?: string | null, focus = true) => {
      if (!id) {
        setHighlightedId(null);
        return;
      }

      if (isDisabled(id)) {
        return;
      }

      setHighlightedId(id);
      const element = document.querySelector(
        `[data-id="${safeId(id, baseId)}"]`,
      );
      if (element instanceof HTMLElement && focus) {
        element.focus();
      }
    },
    [baseId, isDisabled],
  );

  // Select the item if it's not disabled.
  const onSelect = useCallback(
    (id: string) => {
      if (isDisabled(id)) {
        return;
      }
      onSelectId?.(id);
      setSelectedId(id);
      setHighlightedId(id);
    },
    [isDisabled, onSelectId],
  );

  // Handle keyboard shortcuts.
  const onKeyDown = useCallback(
    (id: string, event: React.KeyboardEvent) => {
      onKeyDownId?.(id, event);
      if (isDisabled(id)) {
        return;
      }

      const currentIndex = ids.findIndex((indexId) => indexId === id);
      if (currentIndex === -1) {
        return;
      }

      const getValidIdInDirection = (
        direction: 'prev' | 'next',
        full = false,
      ) => {
        if (full) {
          return (
            ids[direction === 'next' ? 'findLast' : 'find'](
              (id) => !isDisabled(id),
            ) ?? null
          );
        }

        const delta = direction === 'next' ? 1 : -1;
        for (let offset = 1; offset <= ids.length; offset += 1) {
          // Use a modulo to wrap the ids.
          const index =
            (currentIndex + offset * delta + ids.length) % ids.length;
          const indexId = ids[index];
          if (indexId && !isDisabled(indexId)) {
            return indexId;
          }
        }
        return null;
      };

      let foundKey = true;
      switch (event.key) {
        case ' ':
        case 'Enter':
          onSelect(id);
          break;
        case 'ArrowDown':
          onHighlight(getValidIdInDirection('next'));
          break;
        case 'ArrowUp':
          onHighlight(getValidIdInDirection('prev'));
          break;
        case 'Tab':
          onHighlight(
            event.shiftKey
              ? getValidIdInDirection('prev')
              : getValidIdInDirection('next'),
          );
          break;
        case 'Home':
          onHighlight(getValidIdInDirection('prev', true));
          break;
        case 'End':
          onHighlight(getValidIdInDirection('next', true));
          break;
        default:
          foundKey = false;
      }

      if (foundKey) {
        event.preventDefault();
      }
    },
    [ids, isDisabled, onHighlight, onKeyDownId, onSelect],
  );

  // Callback to get props for a given item.
  const getItemProps = useCallback(
    (id: string): ItemComponentProps => {
      const isHighlighted = id === highlightedId;
      const isSelected = id === selectedId;
      return {
        'data-id': safeId(id, baseId),
        'data-highlighted': isHighlighted,
        'aria-disabled': isDisabled(id),
        'aria-selected': isSelected,
        // Only allow focus if the item is highlighted.
        tabIndex: isHighlighted ? 0 : -1,
        onClick: (event) => {
          onClickId?.(id, event);
          onSelect(id);
        },
        onFocus: (event) => {
          onFocusId?.(id, event);
          if (highlightedId !== id) {
            setHighlightedId(id);
          }
        },
        onKeyDown: (event) => {
          onKeyDown(id, event);
        },
        onMouseEnter: (event) => {
          onMouseEnterId?.(id, event);
          if (highlightedId !== id) {
            setHighlightedId(id);
          }
        },
      };
    },
    [
      baseId,
      highlightedId,
      isDisabled,
      onClickId,
      onFocusId,
      onKeyDown,
      onMouseEnterId,
      onSelect,
      selectedId,
    ],
  );

  return useMemo(
    () => ({
      // Has a stable referenced map of id to props in case getItemProps is causing unneeded re-renders.
      idProps: ids.reduce<Record<string, ItemComponentProps>>((map, id) => {
        map[id] = getItemProps(id);
        return map;
      }, {}),
      getItemProps,
      selectedId,
      onSelect,
      highlightedId,
      onHighlight,
    }),
    [getItemProps, highlightedId, ids, onHighlight, onSelect, selectedId],
  );
}

interface ListItem {
  id: string | number;
  disabled?: boolean;
}

export function useListItemsFocus({
  items,
  ...rest
}: Omit<UseListFocusArgs, 'ids' | 'getIsIdDisabled'> & {
  items: ListItem[];
}) {
  const ids = useMemo(() => items.map(({ id }) => id.toString()), [items]);
  const getIsIdDisabled = useCallback(
    (id: string) => !!items.find(({ id: itemId }) => id === itemId)?.disabled,
    [items],
  );
  return useListFocus({
    ids,
    getIsIdDisabled,
    ...rest,
  });
}

function safeId(id: string, baseId: string) {
  return CSS.escape(`${baseId}-${id}`);
}

function idToElement(id: string, baseId: string) {
  return document.querySelector(`[data-id="${safeId(id, baseId)}"]`);
}
