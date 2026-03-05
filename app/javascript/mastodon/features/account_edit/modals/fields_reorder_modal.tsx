import type { FC } from 'react';
import { useState, useCallback } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import type {
  UniqueIdentifier,
  DragStartEvent,
  DragEndEvent,
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
  arrayMove,
  sortableKeyboardCoordinates,
  SortableContext,
  useSortable,
} from '@dnd-kit/sortable';

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
  save: {
    id: 'account_edit.save',
    defaultMessage: 'Save',
  },
});

export const ReorderFieldsModal: FC<DialogModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const { profile } = useAppSelector((state) => state.profileEdit);
  const fields = profile?.fields ?? [];
  const [fieldKeys, setFieldKeys] = useState<string[]>(
    fields.map((field) => field.id),
  );

  const [, setActiveId] = useState<UniqueIdentifier | null>(null);

  const handleDragStart = useCallback(
    (event: DragStartEvent) => {
      const { active } = event;

      setActiveId(active.id);
    },
    [setActiveId],
  );

  const handleDragEnd = useCallback(
    (event: DragEndEvent) => {
      const { active, over } = event;

      setFieldKeys((prev) => {
        if (!over) {
          return prev;
        }
        const oldIndex = prev.indexOf(active.id as string);
        const newIndex = prev.indexOf(over.id as string);

        return arrayMove(prev, oldIndex, newIndex);
      });

      setActiveId(null);
    },
    [setActiveId],
  );

  const handleDragCancel = useCallback(() => {
    setActiveId(null);
  }, [setActiveId]);

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
    >
      <DndContext
        sensors={sensors}
        collisionDetection={closestCenter}
        onDragStart={handleDragStart}
        onDragEnd={handleDragEnd}
        onDragCancel={handleDragCancel}
        onDragAbort={handleDragCancel}
      >
        <SortableContext items={fieldKeys}>
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
  const { attributes, listeners, setNodeRef } = useSortable({ id });
  const field = useAppSelector((state) => selectFieldById(state, id));

  if (!field) {
    return null;
  }

  return (
    <li
      ref={setNodeRef}
      className={classes.field}
      {...attributes}
      {...listeners}
    >
      <Icon icon={DragIndicatorIcon} id='drag' />
      <AccountField {...field} />
    </li>
  );
};
