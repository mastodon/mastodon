import type React from 'react';
import { useCallback, useMemo, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';

import type {
  Announcements,
  DragEndEvent,
  DragStartEvent,
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
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { DotsSixVerticalIcon } from '@phosphor-icons/react';

import { rearrangeComposeAttachments } from '@/mastodon/actions/compose_typed';
import { Button, IconButton } from '@/mastodon/components/button/redesign';
import { normalizeKey } from '@/mastodon/components/hotkeys/utils';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import classes from './modals.module.scss';
import { selectComposeAttachment, selectComposeAttachments } from './selectors';

const messages = defineMessages({
  screenReaderInstructions: {
    id: 'compose.rearrange_modal.drag_instructions',
    defaultMessage:
      'To rearrange attachments, press space or enter. While dragging, use the arrow keys to move the attachment up or down. Press space or enter again to drop the attachment in its new position, or press escape to cancel.',
  },
  onDragStart: {
    id: 'compose.rearrange_modal.drag_start',
    defaultMessage: 'Picked up attachment at index {index, number}.',
  },
  onDragMove: {
    id: 'compose.rearrange_modal.drag_move',
    defaultMessage: 'Attachment index {index, number} was moved.',
  },
  onDragMoveOver: {
    id: 'compose.rearrange_modal.drag_over',
    defaultMessage:
      'Attachment index {index, number} was moved over index {over, number}.',
  },
  onDragEnd: {
    id: 'compose.rearrange_modal.drag_end',
    defaultMessage:
      'Attachment index {index, number} was moved to index {newIndex, number}.',
  },
  onDragCancel: {
    id: 'compose.rearrange_modal.drag_cancel',
    defaultMessage:
      'Dragging was cancelled. Attachment index {index, number} was dropped.',
  },
});

const ComposerModalRearrange: React.FC<{ onClose: () => void }> = ({
  onClose,
}) => {
  const attachments = useAppSelector(selectComposeAttachments);
  const [attachmentIds, setAttachmentIds] = useState(() =>
    attachments.map(({ id }) => id),
  );
  const [activeId, setActiveId] = useState<UniqueIdentifier | null>(null);

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

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    dispatch(rearrangeComposeAttachments(attachmentIds));
    onClose();
  }, [attachmentIds, dispatch, onClose]);

  // Combines the Escape shortcut for closing the modal and for cancelling the drag, depending on the current state.
  const handleEscape: React.KeyboardEventHandler = useCallback(
    (event) => {
      const key = normalizeKey(event.key);

      if (key === 'escape') {
        // Stops propagation to avoid triggering the handler in ModalRoot.
        event.stopPropagation();

        // Trigger the drag cancel here, since onDragCancel triggers before this handler.
        if (activeId !== null) {
          setActiveId(null);
        } else {
          onClose();
        }
      }
    },
    [activeId, onClose],
  );

  // Drag handlers
  const handleDragStart = useCallback((event: DragStartEvent) => {
    setActiveId(event.active.id);
  }, []);

  const handleDragEnd = useCallback((event: DragEndEvent) => {
    const { active, over } = event;

    setAttachmentIds((prev) => {
      if (!over) {
        return prev;
      }
      const oldIndex = prev.indexOf(active.id as string);
      const newIndex = prev.indexOf(over.id as string);

      return arrayMove(prev, oldIndex, newIndex);
    });
    setActiveId(null);
  }, []);

  // Accessibility
  const intl = useIntl();
  const activeToIndex = useCallback(
    (active: { id: UniqueIdentifier } | null) => {
      if (!active) {
        return 0;
      }
      return attachmentIds.indexOf(String(active.id)) + 1;
    },
    [attachmentIds],
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
            index: activeToIndex(active),
          });
        },

        onDragOver({ active, over }) {
          if (over && active.id !== over.id) {
            return intl.formatMessage(messages.onDragMoveOver, {
              index: activeToIndex(active),
              over: activeToIndex(over),
            });
          }
          return intl.formatMessage(messages.onDragMove, {
            index: activeToIndex(active),
          });
        },

        onDragEnd({ active, over }) {
          return intl.formatMessage(messages.onDragEnd, {
            index: activeToIndex(active),
            newIndex: activeToIndex(over),
          });
        },

        onDragCancel({ active }) {
          return intl.formatMessage(messages.onDragCancel, {
            index: activeToIndex(active),
          });
        },
      },
    }),
    [activeToIndex, intl],
  );

  return (
    <div
      className={classNames(classes.root, classes.attachmentRoot)}
      onKeyUpCapture={handleEscape}
    >
      <h2 className={classes.title}>
        <FormattedMessage
          id='compose.rearrange_modal.title'
          defaultMessage='Rearrange media'
        />
      </h2>

      <DndContext
        sensors={sensors}
        onDragStart={handleDragStart}
        onDragEnd={handleDragEnd}
        modifiers={[restrictToVerticalAxis, restrictToParentElement]}
        accessibility={accessibility}
      >
        <ol className={classes.attachmentList}>
          <SortableContext
            items={attachmentIds}
            strategy={verticalListSortingStrategy}
          >
            {attachmentIds.map((id) => (
              <ComposeRearrangeItem key={id} id={id} />
            ))}
          </SortableContext>
        </ol>

        <DragOverlay dropAnimation={null}>
          <div
            className={classNames(
              classes.attachmentItem,
              classes.attachmentOverlay,
            )}
          >
            {typeof activeId === 'string' && (
              <ComposeRearrangeItemDisplay
                id={activeId}
                index={attachmentIds.indexOf(activeId)}
                aria-pressed
              />
            )}
          </div>
        </DragOverlay>
      </DndContext>

      <div className={classes.footer}>
        <Button onClick={onClose}>
          <FormattedMessage
            id='compose.rearrange_modal.cancel'
            defaultMessage='Cancel'
          />
        </Button>

        <Button color='neutral' onClick={handleSave}>
          <FormattedMessage
            id='compose.rearrange_modal.save'
            defaultMessage='Save'
          />
        </Button>
      </div>
    </div>
  );
};

const ComposeRearrangeItem: React.FC<{ id: string }> = ({ id }) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    index,
    isDragging,
  } = useSortable({
    id,
  });

  const style = {
    transform: CSS.Translate.toString(transform),
    ['--transition']: transition,
  } as React.CSSProperties;

  return (
    <li
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      className={classNames(
        classes.attachmentItem,
        isDragging && classes.attachmentGrabbed,
      )}
    >
      <ComposeRearrangeItemDisplay id={id} index={index} />
    </li>
  );
};

const ComposeRearrangeItemDisplay: React.FC<
  {
    id: string;
    index: number;
  } & Omit<React.ComponentPropsWithRef<'button'>, 'children' | 'id' | 'color'>
> = ({ id, index, className, ...props }) => {
  const attachment = useAppSelector((state) =>
    selectComposeAttachment(state, id),
  );

  return (
    <>
      <IconButton
        {...props}
        icon={DotsSixVerticalIcon}
        className={classNames(className, classes.attachmentHandle)}
      >
        <FormattedMessage
          id='compose.rearrange_modal.handle'
          defaultMessage='Drag attachment at position {index, number}'
          values={{ index: index + 1 }}
        />
      </IconButton>

      {attachment && (
        <img
          src={attachment.preview_url || attachment.url}
          alt={attachment.description}
        />
      )}
    </>
  );
};

// eslint-disable-next-line import/no-default-export -- Modals import from default
export default ComposerModalRearrange;
