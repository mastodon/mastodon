import type { FC, KeyboardEventHandler } from 'react';
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

import { CustomEmojiProvider } from '@/mastodon/components/emoji/context';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import { Icon } from '@/mastodon/components/icon';
import type { FieldData } from '@/mastodon/reducers/slices/profile_edit';
import {
  patchProfile,
  selectFieldById,
} from '@/mastodon/reducers/slices/profile_edit';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';
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
  handleLabel: {
    id: 'account_edit.field_reorder_modal.handle_label',
    defaultMessage: 'Drag field "{item}"',
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

const selectFields = createAppSelector(
  [(state) => state.profileEdit],
  ({ isPending, profile }) => ({
    isPending: isPending,
    fields: profile?.fields ?? [],
  }),
);

export const ReorderFieldsModal: FC<DialogModalProps> = ({ onClose }) => {
  const intl = useIntl();
  const { fields, isPending } = useAppSelector(selectFields);
  const [fieldKeys, setFieldKeys] = useState<string[]>(
    fields.map((field) => field.id),
  );

  const [isDragging, setIsDragging] = useState(false);
  const handleDragStart = useCallback(() => {
    setIsDragging(true);
  }, []);
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
    setIsDragging(false);
  }, []);

  // Combines the Escape shortcut for closing the modal and for cancelling the drag, depending on the current state.
  const handleEscape: KeyboardEventHandler = useCallback(
    (event) => {
      const key = normalizeKey(event.key);
      if (key === 'Escape') {
        // Stops propagation to avoid triggering the handler in ModalRoot.
        event.stopPropagation();

        // Trigger the drag cancel here, since onDragCancel triggers before this handler.
        if (isDragging) {
          setIsDragging(false);
        } else {
          onClose();
        }
      }
    },
    [isDragging, onClose],
  );

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

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    const newFields: Pick<FieldData, 'name' | 'value'>[] = [];
    for (const key of fieldKeys) {
      const field = fields.find((f) => f.id === key);
      if (!field) {
        console.warn(`Field with id ${key} not found, closing modal.`);
        onClose();
        return;
      }
      newFields.push({ name: field.name, value: field.value });
    }

    void dispatch(patchProfile({ fields_attributes: newFields })).then(onClose);
  }, [dispatch, fieldKeys, fields, onClose]);

  const emojis = useAppSelector((state) => state.custom_emojis);

  return (
    // Add a wrapper here in the capture phase, so that it can be intercepted before the window listener in ModalRoot.
    <div onKeyUpCapture={handleEscape}>
      <ConfirmationModal
        onClose={onClose}
        title={intl.formatMessage(messages.rearrangeTitle)}
        confirm={intl.formatMessage(messages.save)}
        onConfirm={handleSave}
        className={classes.wrapper}
        updating={isPending}
        noFocusButton
      >
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragStart={handleDragStart}
          onDragEnd={handleDragEnd}
          modifiers={[restrictToVerticalAxis, restrictToParentElement]}
          accessibility={accessibility}
        >
          <SortableContext
            items={fieldKeys}
            strategy={verticalListSortingStrategy}
            disabled={isPending}
          >
            <CustomEmojiProvider emojis={emojis}>
              <ol>
                {fieldKeys.map((key) => (
                  <ReorderFieldItem key={key} id={key} />
                ))}
              </ol>
            </CustomEmojiProvider>
          </SortableContext>
        </DndContext>
      </ConfirmationModal>
    </div>
  );
};

const ReorderFieldItem: FC<{ id: string }> = ({ id }) => {
  const intl = useIntl();
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
        aria-label={intl.formatMessage(messages.handleLabel, {
          item: field.name,
        })}
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
