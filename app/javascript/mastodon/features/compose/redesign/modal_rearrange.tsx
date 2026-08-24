import type React from 'react';
import { useCallback, useState } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { UniqueIdentifier } from '@dnd-kit/core';
import { DotsSixVerticalIcon } from '@phosphor-icons/react';

import { rearrangeComposeAttachments } from '@/mastodon/actions/compose_typed';
import { Button, IconButton } from '@/mastodon/components/button/redesign';
import {
  ModalActions,
  ModalShell,
  ModalTitle,
} from '@/mastodon/components/modal_shell/redesign';
import {
  SortableList,
  SortableListItem,
} from '@/mastodon/components/sortable_list';
import { useSortableList } from '@/mastodon/components/sortable_list/hooks';
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
    defaultMessage: 'Picked up attachment at index {item, number}.',
  },
  onDragMove: {
    id: 'compose.rearrange_modal.drag_move',
    defaultMessage: 'Attachment index {item, number} was moved.',
  },
  onDragMoveOver: {
    id: 'compose.rearrange_modal.drag_over',
    defaultMessage:
      'Attachment index {item, number} was moved over index {over, number}.',
  },
  onDragEnd: {
    id: 'compose.rearrange_modal.drag_end',
    defaultMessage:
      'Attachment index {item, number} was moved to index {over, number}.',
  },
  onDragCancel: {
    id: 'compose.rearrange_modal.drag_cancel',
    defaultMessage:
      'Dragging was cancelled. Attachment index {item, number} was dropped.',
  },
});

const ComposerModalRearrange: React.FC<{ onClose: () => void }> = ({
  onClose,
}) => {
  const attachments = useAppSelector(selectComposeAttachments);
  const [attachmentIds, setAttachmentIds] = useState(() =>
    attachments.map(({ id }) => id),
  );

  const { activeId, onDragStart, onDragEnd, onModalExit } = useSortableList({
    onCancel: onClose,
  });

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    dispatch(rearrangeComposeAttachments(attachmentIds));
    onClose();
  }, [attachmentIds, dispatch, onClose]);

  const activeToIndex = useCallback(
    (active: { id: UniqueIdentifier } | null) => {
      if (!active) {
        return '0';
      }
      return (attachmentIds.indexOf(String(active.id)) + 1).toString();
    },
    [attachmentIds],
  );

  return (
    <ModalShell className={classes.attachmentRoot} onKeyUpCapture={onModalExit}>
      <ModalTitle className={classes.title}>
        <FormattedMessage
          id='compose.rearrange_modal.title'
          defaultMessage='Rearrange media'
        />
      </ModalTitle>

      <SortableList
        ids={attachmentIds}
        onSort={setAttachmentIds}
        onDragStart={onDragStart}
        onDragEnd={onDragEnd}
        messages={messages}
        messageLabelCb={activeToIndex}
        overlay={<ComposeOverlay activeId={activeId} ids={attachmentIds} />}
        dropAnimation={null}
      >
        {attachmentIds.map((id) => (
          <SortableListItem
            id={id}
            key={id}
            noTransition
            className={classes.attachmentItem}
            draggingClassName={classes.attachmentGrabbed}
          >
            <ComposeRearrangeItemDisplay
              id={id}
              index={attachmentIds.indexOf(id)}
            />
          </SortableListItem>
        ))}
      </SortableList>

      <ModalActions className={classes.footer}>
        <Button onClick={onClose}>
          <FormattedMessage
            id='compose.rearrange_modal.cancel'
            defaultMessage='Cancel'
          />
        </Button>

        <Button variant='solid' onClick={handleSave}>
          <FormattedMessage
            id='compose.rearrange_modal.save'
            defaultMessage='Save'
          />
        </Button>
      </ModalActions>
    </ModalShell>
  );
};

const ComposeOverlay: React.FC<{
  activeId: UniqueIdentifier | null;
  ids: string[];
}> = ({ activeId, ids }) => (
  <div
    className={classNames(classes.attachmentItem, classes.attachmentOverlay)}
  >
    {typeof activeId === 'string' && (
      <ComposeRearrangeItemDisplay
        id={activeId}
        index={ids.indexOf(activeId)}
        aria-pressed
      />
    )}
  </div>
);

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
