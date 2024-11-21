import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import CloseIcon from '@/material-icons/400-20px/close.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import {
  undoUploadCompose,
  initMediaEditModal,
} from 'mastodon/actions/compose';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon } from 'mastodon/components/icon';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

export const Upload: React.FC<{
  id: string;
  dragging?: boolean;
  overlay?: boolean;
  tall?: boolean;
  wide?: boolean;
}> = ({ id, dragging, overlay, tall, wide }) => {
  const dispatch = useAppDispatch();
  const media = useAppSelector(
    (state) =>
      state.compose // eslint-disable-line @typescript-eslint/no-unsafe-call
        .get('media_attachments') // eslint-disable-line @typescript-eslint/no-unsafe-member-access
        .find((item: MediaAttachment) => item.get('id') === id) as  // eslint-disable-line @typescript-eslint/no-unsafe-member-access
        | MediaAttachment
        | undefined,
  );
  const sensitive = useAppSelector(
    (state) => state.compose.get('spoiler') as boolean, // eslint-disable-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
  );

  const handleUndoClick = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  const handleFocalPointClick = useCallback(() => {
    dispatch(initMediaEditModal(id));
  }, [dispatch, id]);

  const { attributes, listeners, setNodeRef, transform, transition } =
    useSortable({ id });

  if (!media) {
    return null;
  }

  const focusX = media.getIn(['meta', 'focus', 'x']) as number;
  const focusY = media.getIn(['meta', 'focus', 'y']) as number;
  const x = (focusX / 2 + 0.5) * 100;
  const y = (focusY / -2 + 0.5) * 100;
  const missingDescription =
    ((media.get('description') as string | undefined) ?? '').length === 0;

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      className={classNames('compose-form__upload media-gallery__item', {
        dragging,
        overlay,
        'media-gallery__item--tall': tall,
        'media-gallery__item--wide': wide,
      })}
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
    >
      <div
        className='compose-form__upload__thumbnail'
        style={{
          backgroundImage: !sensitive
            ? `url(${media.get('preview_url') as string})`
            : undefined,
          backgroundPosition: `${x}% ${y}%`,
        }}
      >
        {sensitive && (
          <Blurhash
            hash={media.get('blurhash') as string}
            className='compose-form__upload__preview'
          />
        )}

        <div className='compose-form__upload__actions'>
          <button
            type='button'
            className='icon-button compose-form__upload__delete'
            onClick={handleUndoClick}
          >
            <Icon id='close' icon={CloseIcon} />
          </button>
          <button
            type='button'
            className='icon-button'
            onClick={handleFocalPointClick}
          >
            <Icon id='edit' icon={EditIcon} />{' '}
            <FormattedMessage id='upload_form.edit' defaultMessage='Edit' />
          </button>
        </div>

        <div className='compose-form__upload__warning'>
          <button
            type='button'
            className={classNames('icon-button', {
              active: missingDescription,
            })}
            onClick={handleFocalPointClick}
          >
            {missingDescription && <Icon id='warning' icon={WarningIcon} />} ALT
          </button>
        </div>
      </div>
    </div>
  );
};
