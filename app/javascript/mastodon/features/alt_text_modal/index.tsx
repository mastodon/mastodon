import {
  useState,
  useCallback,
  useRef,
  useImperativeHandle,
  forwardRef,
} from 'react';

import { FormattedMessage, useIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import type { List as ImmutableList, Map as ImmutableMap } from 'immutable';

import { useSpring, animated } from '@react-spring/web';
import Textarea from 'react-textarea-autosize';
import { length } from 'stringz';

import { showAlertForError } from 'mastodon/actions/alerts';
import { uploadThumbnail } from 'mastodon/actions/compose';
import { changeUploadCompose } from 'mastodon/actions/compose_typed';
import { Button } from 'mastodon/components/button';
import { GIFV } from 'mastodon/components/gifv';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { Skeleton } from 'mastodon/components/skeleton';
import { Audio } from 'mastodon/features/audio';
import { CharacterCounter } from 'mastodon/features/compose/components/character_counter';
import { Tesseract as fetchTesseract } from 'mastodon/features/ui/util/async-components';
import { Video, getPointerPosition } from 'mastodon/features/video';
import { me } from 'mastodon/initial_state';
import type { MediaAttachment } from 'mastodon/models/media_attachment';
import { useAppSelector, useAppDispatch } from 'mastodon/store';
import { assetHost } from 'mastodon/utils/config';

import { InfoButton } from './components/info_button';

const messages = defineMessages({
  placeholderVisual: {
    id: 'alt_text_modal.describe_for_people_with_visual_impairments',
    defaultMessage: 'Describe this for people with visual impairments…',
  },
  placeholderHearing: {
    id: 'alt_text_modal.describe_for_people_with_hearing_impairments',
    defaultMessage: 'Describe this for people with hearing impairments…',
  },
  discardMessage: {
    id: 'confirmations.discard_edit_media.message',
    defaultMessage:
      'You have unsaved changes to the media description or preview, discard them anyway?',
  },
  discardConfirm: {
    id: 'confirmations.discard_edit_media.confirm',
    defaultMessage: 'Discard',
  },
});

const MAX_LENGTH = 1500;

type FocalPoint = [number, number];

const UploadButton: React.FC<{
  children: React.ReactNode;
  onSelectFile: (arg0: File) => void;
  mimeTypes: string;
}> = ({ children, onSelectFile, mimeTypes }) => {
  const fileRef = useRef<HTMLInputElement>(null);

  const handleClick = useCallback(() => {
    fileRef.current?.click();
  }, []);

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];

      if (file) {
        onSelectFile(file);
      }
    },
    [onSelectFile],
  );

  return (
    <label>
      <Button onClick={handleClick}>{children}</Button>

      <input
        id='upload-modal__thumbnail'
        ref={fileRef}
        type='file'
        accept={mimeTypes}
        onChange={handleChange}
        style={{ display: 'none' }}
      />
    </label>
  );
};

const Preview: React.FC<{
  mediaId: string;
  position: FocalPoint;
  onPositionChange: (arg0: FocalPoint) => void;
}> = ({ mediaId, position, onPositionChange }) => {
  const nodeRef = useRef<HTMLImageElement | HTMLVideoElement | null>(null);

  const [dragging, setDragging] = useState<'started' | 'moving' | null>(null);

  const [x, y] = position;
  const style = useSpring({
    to: {
      left: `${x * 100}%`,
      top: `${y * 100}%`,
    },
    immediate: dragging === 'moving',
  });
  const media = useAppSelector((state) =>
    (
      (state.compose as ImmutableMap<string, unknown>).get(
        'media_attachments',
      ) as ImmutableList<MediaAttachment>
    ).find((x) => x.get('id') === mediaId),
  );
  const account = useAppSelector((state) =>
    me ? state.accounts.get(me) : undefined,
  );

  const setRef = useCallback(
    (e: HTMLImageElement | HTMLVideoElement | null) => {
      nodeRef.current = e;
    },
    [],
  );

  const handleMouseDown = useCallback(
    (e: React.MouseEvent) => {
      if (e.button !== 0) {
        return;
      }

      const handleMouseMove = (e: MouseEvent) => {
        const { x, y } = getPointerPosition(nodeRef.current, e);

        setDragging('moving'); // This will disable the animation for quicker feedback, only do this if the mouse actually moves
        onPositionChange([x, y]);
      };

      const handleMouseUp = () => {
        setDragging(null);
        document.removeEventListener('mouseup', handleMouseUp);
        document.removeEventListener('mousemove', handleMouseMove);
      };

      const { x, y } = getPointerPosition(nodeRef.current, e.nativeEvent);

      setDragging('started');
      onPositionChange([x, y]);

      document.addEventListener('mouseup', handleMouseUp);
      document.addEventListener('mousemove', handleMouseMove);
    },
    [setDragging, onPositionChange],
  );

  if (!media) {
    return null;
  }

  if (media.get('type') === 'image') {
    return (
      <div className={classNames('focal-point', { dragging })}>
        <img
          ref={setRef}
          draggable={false}
          src={media.get('url') as string}
          alt=''
          role='presentation'
          onMouseDown={handleMouseDown}
        />
        <animated.div className='focal-point__reticle' style={style} />
      </div>
    );
  } else if (media.get('type') === 'gifv') {
    return (
      <div className={classNames('focal-point', { dragging })}>
        <GIFV
          ref={setRef}
          src={media.get('url') as string}
          alt=''
          onMouseDown={handleMouseDown}
        />
        <animated.div className='focal-point__reticle' style={style} />
      </div>
    );
  } else if (media.get('type') === 'video') {
    return (
      <Video
        preview={media.get('preview_url') as string}
        frameRate={media.getIn(['meta', 'original', 'frame_rate']) as string}
        aspectRatio={`${media.getIn(['meta', 'original', 'width']) as number} / ${media.getIn(['meta', 'original', 'height']) as number}`}
        blurhash={media.get('blurhash') as string}
        src={media.get('url') as string}
        detailed
        editable
      />
    );
  } else if (media.get('type') === 'audio') {
    return (
      <Audio
        src={media.get('url') as string}
        poster={
          (media.get('preview_url') as string | undefined) ??
          account?.avatar_static
        }
        duration={media.getIn(['meta', 'original', 'duration'], 0) as number}
        backgroundColor={
          media.getIn(['meta', 'colors', 'background']) as string
        }
        foregroundColor={
          media.getIn(['meta', 'colors', 'foreground']) as string
        }
        accentColor={media.getIn(['meta', 'colors', 'accent']) as string}
        editable
      />
    );
  } else {
    return null;
  }
};

interface RestoreProps {
  previousDescription: string;
  previousPosition: FocalPoint;
}

interface Props {
  mediaId: string;
  onClose: () => void;
}

interface ConfirmationMessage {
  message: string;
  confirm: string;
  props?: RestoreProps;
}

export interface ModalRef {
  getCloseConfirmationMessage: () => null | ConfirmationMessage;
}

export const AltTextModal = forwardRef<ModalRef, Props & Partial<RestoreProps>>(
  ({ mediaId, previousDescription, previousPosition, onClose }, ref) => {
    const intl = useIntl();
    const dispatch = useAppDispatch();
    const media = useAppSelector((state) =>
      (
        (state.compose as ImmutableMap<string, unknown>).get(
          'media_attachments',
        ) as ImmutableList<MediaAttachment>
      ).find((x) => x.get('id') === mediaId),
    );
    const lang = useAppSelector(
      (state) =>
        (state.compose as ImmutableMap<string, unknown>).get(
          'language',
        ) as string,
    );
    const focusX =
      (media?.getIn(['meta', 'focus', 'x'], 0) as number | undefined) ?? 0;
    const focusY =
      (media?.getIn(['meta', 'focus', 'y'], 0) as number | undefined) ?? 0;
    const [description, setDescription] = useState(
      previousDescription ??
        (media?.get('description') as string | undefined) ??
        '',
    );
    const [position, setPosition] = useState<FocalPoint>(
      previousPosition ?? [focusX / 2 + 0.5, focusY / -2 + 0.5],
    );
    const [isDetecting, setIsDetecting] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const dirtyRef = useRef(
      previousDescription || previousPosition ? true : false,
    );
    const type = media?.get('type') as string;
    const valid = length(description) <= MAX_LENGTH;

    const handleDescriptionChange = useCallback(
      (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        setDescription(e.target.value);
        dirtyRef.current = true;
      },
      [setDescription],
    );

    const handleThumbnailChange = useCallback(
      (file: File) => {
        dispatch(uploadThumbnail(mediaId, file));
      },
      [dispatch, mediaId],
    );

    const handlePositionChange = useCallback(
      (position: FocalPoint) => {
        setPosition(position);
        dirtyRef.current = true;
      },
      [setPosition],
    );

    const handleSubmit = useCallback(() => {
      setIsSaving(true);

      dispatch(
        changeUploadCompose({
          id: mediaId,
          description,
          focus: `${((position[0] - 0.5) * 2).toFixed(2)},${((position[1] - 0.5) * -2).toFixed(2)}`,
        }),
      )
        .then(() => {
          setIsSaving(false);
          dirtyRef.current = false;
          onClose();
          return '';
        })
        .catch((err: unknown) => {
          setIsSaving(false);
          dispatch(showAlertForError(err));
        });
    }, [dispatch, setIsSaving, mediaId, onClose, position, description]);

    const handleKeyDown = useCallback(
      (e: React.KeyboardEvent) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault();

          if (valid) {
            handleSubmit();
          }
        }
      },
      [handleSubmit, valid],
    );

    const handleDetectClick = useCallback(() => {
      setIsDetecting(true);

      fetchTesseract()
        .then(async ({ createWorker }) => {
          const [tesseractWorkerPath, tesseractCorePath] = await Promise.all([
            // eslint-disable-next-line import/extensions
            import('tesseract.js/dist/worker.min.js?url'),
            // eslint-disable-next-line import/no-extraneous-dependencies
            import('tesseract.js-core/tesseract-core.wasm.js?url'),
          ]);
          const worker = await createWorker('eng', 1, {
            workerPath: tesseractWorkerPath.default,
            corePath: tesseractCorePath.default,
            langPath: `${assetHost}/ocr/lang-data`,
            cacheMethod: 'write',
          });

          const image = URL.createObjectURL(media?.get('file') as File);
          const result = await worker.recognize(image);

          setDescription(result.data.text);
          setIsDetecting(false);

          await worker.terminate();

          return '';
        })
        .catch(() => {
          setIsDetecting(false);
        });
    }, [setDescription, setIsDetecting, media]);

    useImperativeHandle(
      ref,
      () => ({
        getCloseConfirmationMessage: () => {
          if (dirtyRef.current) {
            return {
              message: intl.formatMessage(messages.discardMessage),
              confirm: intl.formatMessage(messages.discardConfirm),
              props: {
                previousDescription: description,
                previousPosition: position,
              },
            };
          }

          return null;
        },
      }),
      [intl, description, position],
    );

    return (
      <div className='modal-root__modal dialog-modal'>
        <div className='dialog-modal__header'>
          <Button onClick={handleSubmit} disabled={!valid}>
            {isSaving ? (
              <LoadingIndicator />
            ) : (
              <FormattedMessage
                id='alt_text_modal.done'
                defaultMessage='Done'
              />
            )}
          </Button>

          <span className='dialog-modal__header__title'>
            <FormattedMessage
              id='alt_text_modal.add_alt_text'
              defaultMessage='Add alt text'
            />
          </span>

          <Button secondary onClick={onClose}>
            <FormattedMessage
              id='alt_text_modal.cancel'
              defaultMessage='Cancel'
            />
          </Button>
        </div>

        <div className='dialog-modal__content'>
          <div className='dialog-modal__content__preview'>
            <Preview
              mediaId={mediaId}
              position={position}
              onPositionChange={handlePositionChange}
            />

            {(type === 'audio' || type === 'video') && (
              <UploadButton
                onSelectFile={handleThumbnailChange}
                mimeTypes='image/jpeg,image/png,image/gif,image/heic,image/heif,image/webp,image/avif'
              >
                <FormattedMessage
                  id='alt_text_modal.change_thumbnail'
                  defaultMessage='Change thumbnail'
                />
              </UploadButton>
            )}
          </div>

          <form
            className='dialog-modal__content__form simple_form'
            onSubmit={handleSubmit}
          >
            <div className='input'>
              <div className='label_input'>
                <Textarea
                  id='description'
                  value={isDetecting ? ' ' : description}
                  onChange={handleDescriptionChange}
                  onKeyDown={handleKeyDown}
                  lang={lang}
                  placeholder={intl.formatMessage(
                    type === 'audio'
                      ? messages.placeholderHearing
                      : messages.placeholderVisual,
                  )}
                  minRows={3}
                  disabled={isDetecting}
                />

                {isDetecting && (
                  <div className='label_input__loading-indicator'>
                    <Skeleton width='100%' />
                    <Skeleton width='100%' />
                    <Skeleton width='61%' />
                  </div>
                )}
              </div>

              <div className='input__toolbar'>
                <CharacterCounter
                  max={MAX_LENGTH}
                  text={isDetecting ? '' : description}
                />

                <div className='spacer' />

                <button
                  className='link-button'
                  onClick={handleDetectClick}
                  disabled={type !== 'image' || isDetecting}
                  type='button'
                >
                  <FormattedMessage
                    id='alt_text_modal.add_text_from_image'
                    defaultMessage='Add text from image'
                  />
                </button>

                <InfoButton />
              </div>
            </div>
          </form>
        </div>
      </div>
    );
  },
);
AltTextModal.displayName = 'AltTextModal';
