import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import type { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

import CloseIcon from '@/material-icons/400-20px/close.svg?react';
import EditIcon from '@/material-icons/400-24px/edit.svg?react';
import SoundIcon from '@/material-icons/400-24px/graphic_eq.svg?react';
import WarningIcon from '@/material-icons/400-24px/warning.svg?react';
import { undoUploadCompose } from 'mastodon/actions/compose';
import { openModal } from 'mastodon/actions/modal';
import { Blurhash } from 'mastodon/components/blurhash';
import { Icon } from 'mastodon/components/icon';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from 'mastodon/store';

import { AudioVisualizer } from '../../audio/visualizer';

const selectUserAvatar = createAppSelector(
  [(state) => state.accounts, (state) => state.meta.get('me') as string],
  (accounts, myId) => accounts.get(myId)?.avatar_static,
);

export const Upload: React.FC<{
  id: string;
  dragging?: boolean;
  draggable?: boolean;
  overlay?: boolean;
  tall?: boolean;
  wide?: boolean;
}> = ({ id, dragging, draggable = true, overlay, tall, wide }) => {
  const dispatch = useAppDispatch();
  const media = useAppSelector((state) =>
    (
      (state.compose as ImmutableMap<string, unknown>).get(
        'media_attachments',
      ) as ImmutableList<MediaAttachment>
    ).find((item) => item.get('id') === id),
  );
  const sensitive = useAppSelector(
    (state) => state.compose.get('spoiler') as boolean,
  );
  const userAvatar = useAppSelector(selectUserAvatar);

  const handleUndoClick = useCallback(() => {
    dispatch(undoUploadCompose(id));
  }, [dispatch, id]);

  const handleFocalPointClick = useCallback(() => {
    dispatch(
      openModal({ modalType: 'FOCAL_POINT', modalProps: { mediaId: id } }),
    );
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
  const preview_url = media.get('preview_url') as string | null;
  const blurhash = media.get('blurhash') as string | null;

  return (
    <div
      className={classNames('compose-form__upload media-gallery__item', {
        dragging,
        draggable,
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
          backgroundImage:
            !sensitive && preview_url ? `url(${preview_url})` : undefined,
          backgroundPosition: `${x}% ${y}%`,
        }}
      >
        {sensitive && blurhash && (
          <Blurhash hash={blurhash} className='compose-form__upload__preview' />
        )}
        {!sensitive && !preview_url && (
          <div className='compose-form__upload__visualizer'>
            <AudioVisualizer poster={userAvatar} />
            <Icon id='sound' icon={SoundIcon} />
          </div>
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
