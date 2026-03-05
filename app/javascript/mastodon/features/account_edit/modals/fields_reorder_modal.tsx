import type { FC } from 'react';
import { useState, useCallback, useMemo } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import classNames from 'classnames';

import type {
  DragEndEvent,
  ScreenReaderInstructions,
  Announcements,
  Active,
} from '@dnd-kit/core';
import {
  useSensors,
  useSensor,
  PointerSensor,
  KeyboardSensor,
  DndContext,
  closestCenter,
} from '@dnd-kit/core';
import {
  restrictToVerticalAxis,
  restrictToParentElement,
} from '@dnd-kit/modifiers';
import {
  arrayMove,
  sortableKeyboardCoordinates,
  SortableContext,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import { Icon } from '@/mastodon/components/icon';
import { selectFieldById } from '@/mastodon/reducers/slices/profile_edit';
import { useAppSelector } from '@/mastodon/store';
import DragIndicatorIcon from '@/material-icons/400-24px/drag_indicator.svg?react';

import { ConfirmationModal } from '../../ui/components/confirmation_modals';
import type { DialogModalProps } from '../../ui/components/dialog_modal';
import { AccountField } from '../components/field';

import classes from './styles.module.scss';

const messages = defineMessages({
  rearrangeTitle: {
    id: 'account_edit.field_reorder_modal.title',
    defaultMessage: 'Rearrange fields',
  },
  screenReaderInstructions: {
    id: 'account_edit.field_reorder_modal.drag_instructions',
    defaultMessage:
      'To rearrange custom fields, press space or enter. While dragging, use the arrow keys to move the field up or down. Press space or enter again to drop the field in its new position, or press escape to cancel.',
  },
  onDragStart: {
    id: 'account_edit.field_reorder_modal.drag_start',
    defaultMessage: 'Picked up field "{item}".',
  },
  onDragMove: {
    id: 'account_edit.field_reorder_modal.drag_move',
    defaultMessage: 'Field "{item}" was moved.',
  },
  onDragMoveOver: {
    id: 'account_edit.field_reorder_modal.drag_over',
    defaultMessage: 'Field "{item}" was moved over "{over}".',
  },
  onDragEnd: {
    id: 'account_edit.field_reorder_modal.drag_end',
    defaultMessage: 'Field "{item}" was dropped.',
  },
  onDragCancel: {
    id: 'account_edit.field_reorder_modal.drag_cancel',
    defaultMessage: 'Dragging was cancelled. Field "{item}" was dropped.',
  },
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

export const ReorderFieldsModal: FC<DialogModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const { profile, isPending } = useAppSelector((state) => state.profileEdit);
  const fields = profile?.fields ?? [];
  const [fieldKeys, setFieldKeys] = useState<string[]>(
    fields.map((field) => field.id),
  );

  const handleDragEnd = useCallback((event: DragEndEvent) => {
    const { active, over } = event;

    setFieldKeys((prev) => {
      if (!over) {
        return prev;
      }
      const oldIndex = prev.indexOf(active.id as string);
      const newIndex = prev.indexOf(over.id as string);

      return arrayMove(prev, oldIndex, newIndex);
    });
  }, []);

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

  const accessibility: {
    screenReaderInstructions: ScreenReaderInstructions;
    announcements: Announcements;
  } = useMemo(
    () => ({
      screenReaderInstructions: {
        draggable: intl.formatMessage(messages.screenReaderInstructions),
      },

      announcements: {
        onDragStart({ active }) {
          return intl.formatMessage(messages.onDragStart, {
            item: labelFromActive(active),
          });
        },

        onDragOver({ active, over }) {
          if (over && active.id !== over.id) {
            return intl.formatMessage(messages.onDragMoveOver, {
              item: labelFromActive(active),
              over: labelFromActive(over),
            });
          }
          return intl.formatMessage(messages.onDragMove, {
            item: labelFromActive(active),
          });
        },

        onDragEnd({ active }) {
          return intl.formatMessage(messages.onDragEnd, {
            item: labelFromActive(active),
          });
        },

        onDragCancel({ active }) {
          return intl.formatMessage(messages.onDragCancel, {
            item: labelFromActive(active),
          });
        },
      },
    }),
    [intl],
  );

  const handleSave = useCallback(() => {
    // TODO
  }, []);

  return (
    <ConfirmationModal
      onClose={onClose}
      title={intl.formatMessage(messages.rearrangeTitle)}
      confirm={intl.formatMessage(messages.save)}
      onConfirm={handleSave}
      className={classes.wrapper}
      updating={isPending}
    >
      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragEnd={handleDragEnd}
        modifiers={[restrictToVerticalAxis, restrictToParentElement]}
        accessibility={accessibility}
      >
        <SortableContext
          items={fieldKeys}
          strategy={verticalListSortingStrategy}
          disabled={isPending}
        >
          <ol>
            {fieldKeys.map((key) => (
              <ReorderFieldItem key={key} id={key} />
            ))}
          </ol>
        </SortableContext>
      </DndContext>
    </ConfirmationModal>
  );
};

const ReorderFieldItem: FC<{ id: string }> = ({ id }) => {
  const field = useAppSelector((state) => selectFieldById(state, id));
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
    newIndex,
    overIndex,
  } = useSortable({
    id,
    data: {
      label: field?.name ?? id,
    },
  });

  if (!field) {
    return null;
  }

  const style = {
    transform: CSS.Translate.toString(transform),
    transition,
  };

  return (
    <li
      ref={setNodeRef}
      className={classNames(
        classes.field,
        isDragging && classes.fieldDragging,
        !isDragging && newIndex > 0 && classes.fieldNotFirst,
        !isDragging && newIndex + 1 === overIndex && classes.fieldActiveUnder,
      )}
      style={style}
    >
      <Icon
        icon={DragIndicatorIcon}
        id='drag'
        className={classes.fieldHandle}
        {...listeners}
        {...attributes}
      />
      <AccountField {...field} />
    </li>
  );
};

function labelFromActive(item: Pick<Active, 'id' | 'data'>) {
  if (item.data.current?.label) {
    return item.data.current.label as string;
  }
  return item.id as string;
}
