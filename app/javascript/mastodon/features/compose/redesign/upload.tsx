import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { DotsThreeIcon, PlusIcon, TrashIcon } from '@phosphor-icons/react';

import { undoUploadCompose } from '@/mastodon/actions/compose';
import { openModal } from '@/mastodon/actions/modal';
import { IconButton } from '@/mastodon/components/button/redesign';
import { Icon } from '@/mastodon/components/icon';
import { Popover } from '@/mastodon/components/popover';
import { useToggle } from '@/mastodon/hooks/useToggle';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store';

import { selectComposeAttachments } from './selectors';
import classes from './styles.module.scss';

const selectAttachment = createAppSelector(
  [selectComposeAttachments, (_, id?: string) => id],
  (attachments, id) => {
    if (!id) {
      return null;
    }
    return attachments.find((attachment) => attachment.id === id) ?? null;
  },
);

export const ComposeUpload: React.FC<{ id?: string; className?: string }> = ({
  id,
  className,
}) => {
  const attachment = useAppSelector((state) => selectAttachment(state, id));
  const [open, { onToggle, onFalse }] = useToggle();
  const [target, setTarget] = useState<HTMLButtonElement | null>(null);

  const dispatch = useAppDispatch();
  const handleEdit = useCallback(() => {
    if (id) {
      dispatch(
        openModal({ modalType: 'FOCAL_POINT', modalProps: { mediaId: id } }),
      );
    }
  }, [dispatch, id]);
  const handleDelete = useCallback(() => {
    if (id) {
      dispatch(undoUploadCompose(id));
    }
  }, [dispatch, id]);

  if (!attachment || attachment.type === 'unknown') {
    return <div className={classNames(classes.mediaUpload, className)} />;
  }

  let x = 50;
  let y = 50;
  if (
    attachment.type === 'image' ||
    attachment.type === 'gifv' ||
    attachment.type === 'video'
  ) {
    const focusX = attachment.meta.focus?.x;
    const focusY = attachment.meta.focus?.y;
    if (focusX && focusY) {
      x = (focusX / 2 + 0.5) * 100;
      y = (focusY / -2 + 0.5) * 100;
    }
  }

  return (
    <div
      className={classNames(classes.mediaUpload, className)}
      style={
        {
          backgroundImage: attachment.preview_url
            ? `url(${attachment.preview_url})`
            : undefined,
          backgroundPosition: `${x}% ${y}%`,
          '--width': `${attachment.meta.original.width}px`,
          '--height': `${attachment.meta.original.height}px`,
        } as React.CSSProperties // Cast to allow properties
      }
      data-color-scheme='dark'
    >
      <IconButton
        icon={DotsThreeIcon}
        size='sm'
        color='neutral'
        className={classes.mediaMenuButton}
        onClick={onToggle}
        ref={setTarget}
      >
        <FormattedMessage
          id='compose.upload.menu'
          defaultMessage='Add alt text or remove the image'
        />
      </IconButton>

      <Popover
        isOpen={open}
        onClose={onFalse}
        reference={target}
        placement='bottom-end'
        offset={4}
      >
        {({ props }) => (
          <div
            {...props}
            className={classNames(classes.menu, classes.mediaMenu)}
          >
            <button
              type='button'
              className={classes.menuItemButton}
              onClick={handleEdit}
            >
              <Icon id='plus' icon={PlusIcon} />
              <FormattedMessage
                id='compose.upload.menu.add_alt'
                defaultMessage='Add alt text'
              />
            </button>

            <hr />

            <button
              type='button'
              className={classNames(
                classes.menuItemButton,
                classes.mediaMenuDelete,
              )}
              onClick={handleDelete}
            >
              <Icon id='trash' icon={TrashIcon} />
              <FormattedMessage
                id='compose.upload.menu.delete'
                defaultMessage='Remove image'
              />
            </button>
          </div>
        )}
      </Popover>

      {attachment.description && (
        <span className={classes.mediaAlt}>
          <FormattedMessage id='compose.upload.alt' defaultMessage='Alt' />
        </span>
      )}
    </div>
  );
};
