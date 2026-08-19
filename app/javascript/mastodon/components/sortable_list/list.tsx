import type React from 'react';
import { useCallback, useMemo } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { useIntl } from 'react-intl';

import type {
  Active,
  Announcements,
  DragEndEvent,
  DragStartEvent,
  DropAnimation,
  Over,
  ScreenReaderInstructions,
  UniqueIdentifier,
} from '@dnd-kit/core';
import {
  DndContext,
  DragOverlay,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from '@dnd-kit/core';
import {
  restrictToParentElement,
  restrictToVerticalAxis,
} from '@dnd-kit/modifiers';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import type { SetRequired } from 'type-fest';

import { SortableListItem } from './item';

export type MessageKeys =
  | 'screenReaderInstructions'
  | 'onDragStart'
  | 'onDragMoveOver'
  | 'onDragMove'
  | 'onDragEnd'
  | 'onDragCancel';

export type SortableListMessages = SetRequired<
  Partial<Record<MessageKeys, MessageDescriptor>>,
  'screenReaderInstructions'
>;

type ValidListElement =
  | 'ol'
  | 'ul'
  | 'div'
  | 'section'
  | 'nav'
  | 'article'
  | 'main'
  | 'aside';

interface SortableListOwnProps<
  As extends ValidListElement,
  Id extends UniqueIdentifier = string,
> {
  ids: Id[];
  renderItem?: (id: Id) => React.ReactNode;
  messages?: SortableListMessages;
  messageLabelCb?: (item: Active | Over) => Id;
  as?: As;
  onSort?: (ids: Id[]) => void;
  onDragStart?: (event: DragStartEvent) => void;
  onDragEnd?: (event: DragEndEvent) => void;
  overlay?: React.ReactNode;
  dropAnimation?: DropAnimation | null;
}

export type SortableListProps<
  As extends ValidListElement,
  Id extends UniqueIdentifier,
> = SortableListOwnProps<As, Id> &
  Omit<React.ComponentPropsWithoutRef<As>, keyof SortableListOwnProps<As>>;

export const SortableList = <
  As extends ValidListElement = 'ol',
  Id extends UniqueIdentifier = string,
>({
  ids,
  renderItem,
  as: AsComp,
  onSort,
  onDragStart,
  onDragEnd: onDragEndParent,
  messages,
  children,
  overlay,
  dropAnimation,
  messageLabelCb,
  ...props
}: SortableListProps<As, Id>) => {
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 5,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    }),
  );

  const onDragEnd = useCallback(
    (event: DragEndEvent) => {
      if (onDragEndParent) {
        onDragEndParent(event);
      }
      const { active, over } = event;

      if (!over || !onSort) {
        return;
      }
      const oldIndex = ids.indexOf(active.id as Id);
      const newIndex = ids.indexOf(over.id as Id);

      onSort(arrayMove(ids, oldIndex, newIndex));
    },
    [ids, onDragEndParent, onSort],
  );

  const intl = useIntl();
  const accessibility = useMemo(() => {
    if (!messages) {
      return undefined;
    }

    const itemRender = messageLabelCb ?? (({ id }) => String(id));

    return {
      screenReaderInstructions: {
        draggable: intl.formatMessage(messages.screenReaderInstructions),
      } satisfies ScreenReaderInstructions,

      announcements: {
        onDragStart({ active }) {
          if (!messages.onDragStart) {
            return undefined;
          }
          return intl.formatMessage(messages.onDragStart, {
            item: itemRender(active),
          });
        },

        onDragOver({ active, over }) {
          if (over && active.id !== over.id && messages.onDragMoveOver) {
            return intl.formatMessage(messages.onDragMoveOver, {
              item: itemRender(active),
              over: itemRender(over),
            });
          }

          if (!messages.onDragMove) {
            return undefined;
          }

          return intl.formatMessage(messages.onDragMove, {
            item: itemRender(active),
          });
        },

        onDragEnd({ active, over }) {
          if (!messages.onDragEnd) {
            return undefined;
          }
          return intl.formatMessage(messages.onDragEnd, {
            item: itemRender(active),
            over: over ? itemRender(over) : undefined,
          });
        },

        onDragCancel({ active, over }) {
          if (!messages.onDragCancel) {
            return undefined;
          }
          return intl.formatMessage(messages.onDragCancel, {
            item: itemRender(active),
            over: over ? itemRender(over) : undefined,
          });
        },
      } satisfies Announcements,
    };
  }, [intl, messageLabelCb, messages]);

  const ListComponent = AsComp ?? 'ol';

  return (
    <DndContext
      sensors={sensors}
      onDragStart={onDragStart}
      onDragEnd={onDragEnd}
      modifiers={[restrictToVerticalAxis, restrictToParentElement]}
      accessibility={accessibility}
    >
      <ListComponent {...(props as React.HTMLAttributes<HTMLElement>)}>
        <SortableContext items={ids} strategy={verticalListSortingStrategy}>
          {children ??
            (renderItem &&
              ids.map((id) => (
                <SortableListItem id={id} key={id}>
                  {renderItem(id)}
                </SortableListItem>
              )))}
        </SortableContext>
      </ListComponent>

      {overlay && (
        <DragOverlay dropAnimation={dropAnimation}>{overlay}</DragOverlay>
      )}
    </DndContext>
  );
};
