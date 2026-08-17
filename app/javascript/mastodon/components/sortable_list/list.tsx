import type React from 'react';
import { useCallback, useMemo } from 'react';

import type { MessageDescriptor } from 'react-intl';
import { useIntl } from 'react-intl';

import type {
  Announcements,
  DragEndEvent,
  DragStartEvent,
  ScreenReaderInstructions,
  UniqueIdentifier,
} from '@dnd-kit/core';
import {
  DndContext,
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
  as?: As;
  onSort?: (ids: Id[]) => void;
  onDragStart?: (event: DragStartEvent) => void;
  onDragEnd?: (event: DragEndEvent) => void;
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
            item: active.id,
          });
        },

        onDragOver({ active, over }) {
          if (over && active.id !== over.id && messages.onDragMoveOver) {
            return intl.formatMessage(messages.onDragMoveOver, {
              item: active.id,
              over: over.id,
            });
          }

          if (!messages.onDragMove) {
            return undefined;
          }

          return intl.formatMessage(messages.onDragMove, {
            item: active.id,
          });
        },

        onDragEnd({ active }) {
          if (!messages.onDragEnd) {
            return undefined;
          }
          return intl.formatMessage(messages.onDragEnd, {
            item: active.id,
          });
        },

        onDragCancel({ active }) {
          if (!messages.onDragCancel) {
            return undefined;
          }
          return intl.formatMessage(messages.onDragCancel, {
            item: active.id,
          });
        },
      } satisfies Announcements,
    };
  }, [intl, messages]);

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
    </DndContext>
  );
};
