import { useCallback, useEffect, useRef, useState } from 'react';
import type { ChangeEventHandler, FC } from 'react';

import { defineMessage, FormattedMessage, useIntl } from 'react-intl';

import type { Area } from 'react-easy-crop';
import Cropper from 'react-easy-crop';

import { setDragUploadEnabled } from '@/mastodon/actions/compose_typed';
import { Button } from '@/mastodon/components/button';
import { Callout } from '@/mastodon/components/callout';
import { CharacterCounter } from '@/mastodon/components/character_counter';
import { TextAreaField } from '@/mastodon/components/form_fields';
import { RangeInput } from '@/mastodon/components/form_fields/range_input_field';
import { selectImageInfo } from '@/mastodon/reducers/slices/profile_edit';
import type { ImageLocation } from '@/mastodon/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

import { DialogModal } from '../../ui/components/dialog_modal';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

import classes from './styles.module.scss';

import 'react-easy-crop/react-easy-crop.css';

export const ImageUploadModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose, location }) => {
  const { src: oldSrc } = useAppSelector((state) =>
    selectImageInfo(state, location),
  );
  const hasImage = !!oldSrc;
  const [step, setStep] = useState<'select' | 'crop' | 'alt'>('select');

  // State for individual steps.
  const [imageSrc, setImageSrc] = useState<string | null>(null);
  const [_imageBlob, setImageBlob] = useState<Blob | null>(null);

  const handleFile = useCallback((file: File) => {
    const reader = new FileReader();
    reader.addEventListener('load', () => {
      const result = reader.result;
      if (typeof result === 'string' && result.length > 0) {
        setImageSrc(result);
        setStep('crop');
      }
    });
    reader.readAsDataURL(file);
  }, []);

  const handleCrop = useCallback(
    (crop: Area) => {
      if (!imageSrc) {
        setStep('select');
        return;
      }
      void calculateCroppedImage(imageSrc, crop).then((blob) => {
        setImageBlob(blob);
        setStep('alt');
      });
    },
    [imageSrc],
  );

  const handleCancel = useCallback(() => {
    switch (step) {
      case 'crop':
        setStep('select');
        setImageSrc(null);
        break;
      case 'alt':
        setStep('crop');
        break;
      default:
        onClose();
    }
  }, [onClose, step]);

  return (
    <DialogModal
      title={
        hasImage ? (
          <FormattedMessage
            id='account_edit.upload_modal.title_replace'
            defaultMessage='Replace profile photo'
          />
        ) : (
          <FormattedMessage
            id='account_edit.upload_modal.title_add'
            defaultMessage='Add profile photo'
          />
        )
      }
      onClose={onClose}
      wrapperClassName={classes.uploadWrapper}
      noCancelButton
    >
      {step === 'select' && <StepUpload onFile={handleFile} />}
      {step === 'crop' && imageSrc && (
        <StepCrop
          src={imageSrc}
          onCancel={handleCancel}
          onComplete={handleCrop}
        />
      )}
      {step === 'alt' && <StepAlt onCancel={handleCancel} />}
    </DialogModal>
  );
};

// Taken from app/models/concerns/account/header.rb and app/models/concerns/account/avatar.rb
const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
];

const StepUpload: FC<{ onFile: (file: File) => void }> = ({ onFile }) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const handleUploadClick = useCallback(() => {
    inputRef.current?.click();
  }, []);

  const handleFileChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      const file = event.currentTarget.files?.[0];
      if (!file || !ALLOWED_MIME_TYPES.includes(file.type)) {
        return;
      }
      onFile(file);
    },
    [onFile],
  );

  // Handle drag and drop
  const [isDragging, setDragging] = useState(false);

  const handleDragOver = useCallback((event: DragEvent) => {
    event.preventDefault();
    if (!event.dataTransfer?.types.includes('Files')) {
      return;
    }

    const items = Array.from(event.dataTransfer.items);
    if (
      !items.some(
        (item) =>
          item.kind === 'file' && ALLOWED_MIME_TYPES.includes(item.type),
      )
    ) {
      return;
    }

    setDragging(true);
  }, []);
  const handleDragDrop = useCallback(
    (event: DragEvent) => {
      event.preventDefault();
      setDragging(false);

      if (!event.dataTransfer?.files) {
        return;
      }

      const file = Array.from(event.dataTransfer.files).find((f) =>
        ALLOWED_MIME_TYPES.includes(f.type),
      );
      if (!file) {
        return;
      }

      onFile(file);
    },
    [onFile],
  );
  const handleDragLeave = useCallback((event: DragEvent) => {
    event.preventDefault();
    setDragging(false);
  }, []);

  const dispatch = useAppDispatch();
  useEffect(() => {
    dispatch(setDragUploadEnabled(false));
    document.addEventListener('dragover', handleDragOver);
    document.addEventListener('drop', handleDragDrop);
    document.addEventListener('dragleave', handleDragLeave);

    return () => {
      document.removeEventListener('dragover', handleDragOver);
      document.removeEventListener('drop', handleDragDrop);
      document.removeEventListener('dragleave', handleDragLeave);
      dispatch(setDragUploadEnabled(true));
    };
  }, [handleDragLeave, handleDragDrop, handleDragOver, dispatch]);

  if (isDragging) {
    return (
      <div className={classes.uploadStepSelect}>
        <FormattedMessage
          id='account_edit.upload_modal.step_upload.dragging'
          defaultMessage='Drop to upload'
          tagName='h2'
        />
      </div>
    );
  }

  return (
    <div className={classes.uploadStepSelect}>
      <FormattedMessage
        id='account_edit.upload_modal.step_upload.header'
        defaultMessage='Choose an image'
        tagName='h2'
      />
      <FormattedMessage
        id='account_edit.upload_modal.step_upload.hint'
        defaultMessage='WEBP, PNG, GIF or JPG format, up to 8MB{br}Image will be downscaled to 400x400px'
        values={{ br: <br /> }}
        tagName='p'
      />
      <Button
        onClick={handleUploadClick}
        // eslint-disable-next-line jsx-a11y/no-autofocus -- This is the main input, so auto-focus on it.
        autoFocus
      >
        <FormattedMessage
          id='account_edit.upload_modal.step_upload.button'
          defaultMessage='Browse files'
        />
      </Button>

      <input
        hidden
        type='file'
        ref={inputRef}
        accept={ALLOWED_MIME_TYPES.join(',')}
        onChange={handleFileChange}
      />
    </div>
  );
};

const zoomLabel = defineMessage({
  id: 'account_edit.upload_modal.step_crop.zoom',
  defaultMessage: 'Zoom',
});

const StepCrop: FC<{
  src: string;
  aspect?: number;
  onCancel: () => void;
  onComplete: (crop: Area) => void;
}> = ({ src, aspect = 1, onCancel, onComplete }) => {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [croppedArea, setCroppedArea] = useState<Area | null>(null);
  const [zoom, setZoom] = useState(1);
  const intl = useIntl();

  const handleZoomChange: ChangeEventHandler<HTMLInputElement> = useCallback(
    (event) => {
      setZoom(event.currentTarget.valueAsNumber);
    },
    [],
  );
  const handleCropComplete = useCallback((_: Area, croppedAreaPixels: Area) => {
    setCroppedArea(croppedAreaPixels);
  }, []);

  const handleNext = useCallback(() => {
    if (croppedArea) {
      onComplete(croppedArea);
    }
  }, [croppedArea, onComplete]);

  return (
    <>
      <div className={classes.cropContainer}>
        <Cropper
          image={src}
          crop={crop}
          zoom={zoom}
          onCropChange={setCrop}
          onCropComplete={handleCropComplete}
          aspect={aspect}
          disableAutomaticStylesInjection
        />
      </div>

      <div className={classes.cropActions}>
        <RangeInput
          min={1}
          max={3}
          step={0.1}
          value={zoom}
          onChange={handleZoomChange}
          className={classes.zoomControl}
          aria-label={intl.formatMessage(zoomLabel)}
        />
        <Button onClick={onCancel} secondary>
          <FormattedMessage
            id='account_edit.upload_modal.back'
            defaultMessage='Back'
          />
        </Button>
        <Button onClick={handleNext} disabled={!croppedArea}>
          <FormattedMessage
            id='account_edit.upload_modal.next'
            defaultMessage='Next'
          />
        </Button>
      </div>
    </>
  );
};

const StepAlt: FC<{
  onCancel: () => void;
}> = () => {
  const [altText, setAltText] = useState('');

  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      setAltText(event.currentTarget.value);
    },
    [],
  );

  return (
    <>
      <TextAreaField
        label={
          <FormattedMessage
            id='account_edit.upload_modal.step_alt.text_label'
            defaultMessage='Alt text'
          />
        }
        hint={
          <FormattedMessage
            id='account_edit.upload_modal.step_alt.text_hint'
            defaultMessage='E.g. “Close-up photo of me wearing glasses and a blue shirt”'
          />
        }
        onChange={handleChange}
      />
      <CharacterCounter currentString={altText} maxLength={500} />

      <Callout
        title={
          <FormattedMessage
            id='account_edit.upload_modal.step_alt.callout_title'
            defaultMessage='Let’s make Mastodon accessible for all'
          />
        }
      >
        <FormattedMessage
          id='account_edit.upload_modal.step_alt.callout_text'
          defaultMessage='Adding alt text to media helps people using screen readers to understand your content.'
        />
      </Callout>
    </>
  );
};

async function calculateCroppedImage(
  imageSrc: string,
  crop: Area,
): Promise<Blob> {
  const image = await dataUriToImage(imageSrc);
  const canvas = new OffscreenCanvas(image.naturalWidth, image.naturalHeight);
  const ctx = canvas.getContext('2d');
  if (!ctx) {
    throw new Error('Failed to get canvas context');
  }

  ctx.imageSmoothingQuality = 'high';

  // Save original state.
  ctx.save();

  // Move the crop origin to the canvas origin (0,0).
  const cropX = crop.x;
  const cropY = crop.y;
  ctx.translate(-cropX, -cropY);

  // Move the origin to the center of the original position.
  const centerX = image.naturalWidth / 2;
  const centerY = image.naturalHeight / 2;
  ctx.translate(centerX, centerY);
  ctx.translate(-centerX, -centerY);

  // Draw the image
  ctx.drawImage(
    image,
    0,
    0,
    image.naturalWidth,
    image.naturalHeight,
    0,
    0,
    image.naturalWidth,
    image.naturalHeight,
  );

  // Restore the original state.
  ctx.restore();

  return canvas.convertToBlob({
    quality: 0.7,
    type: 'image/jpeg',
  });
}

function dataUriToImage(dataUri: string) {
  return new Promise<HTMLImageElement>((resolve, reject) => {
    const image = new Image();
    image.addEventListener('load', () => {
      resolve(image);
    });
    image.addEventListener('error', (event) => {
      if (event.error instanceof Error) {
        reject(event.error);
      } else {
        reject(new Error('Failed to load image'));
      }
    });
    image.src = dataUri;
  });
}
