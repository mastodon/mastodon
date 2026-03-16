import type { ChangeEventHandler, FC } from 'react';
import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { CharacterCounter } from '@/flavours/glitch/components/character_counter';
import { Details } from '@/flavours/glitch/components/details';
import { TextAreaField } from '@/flavours/glitch/components/form_fields';
import { LoadingIndicator } from '@/flavours/glitch/components/loading_indicator';
import { patchProfile } from '@/flavours/glitch/reducers/slices/profile_edit';
import type { ImageLocation } from '@/flavours/glitch/reducers/slices/profile_edit';
import { useAppDispatch, useAppSelector } from '@/flavours/glitch/store';

import { ConfirmationModal } from '../../ui/components/confirmation_modals';
import type { DialogModalProps } from '../../ui/components/dialog_modal';

import classes from './styles.module.scss';

export const ImageAltModal: FC<
  DialogModalProps & { location: ImageLocation }
> = ({ onClose, location }) => {
  const { profile, isPending } = useAppSelector((state) => state.profileEdit);

  const initialAlt = profile?.[`${location}Description`];
  const imageSrc = profile?.[`${location}Static`];

  const [altText, setAltText] = useState(initialAlt ?? '');

  const dispatch = useAppDispatch();
  const handleSave = useCallback(() => {
    void dispatch(
      patchProfile({
        [`${location}_description`]: altText,
      }),
    ).then(onClose);
  }, [altText, dispatch, location, onClose]);

  if (!imageSrc) {
    return <LoadingIndicator />;
  }

  return (
    <ConfirmationModal
      title={
        initialAlt ? (
          <FormattedMessage
            id='account_edit.image_alt_modal.edit_title'
            defaultMessage='Edit alt text'
          />
        ) : (
          <FormattedMessage
            id='account_edit.image_alt_modal.add_title'
            defaultMessage='Add alt text'
          />
        )
      }
      onClose={onClose}
      onConfirm={handleSave}
      confirm={
        <FormattedMessage
          id='account_edit.upload_modal.done'
          defaultMessage='Done'
        />
      }
      updating={isPending}
    >
      <div className={classes.wrapper}>
        <ImageAltTextField
          imageSrc={imageSrc}
          altText={altText}
          onChange={setAltText}
        />
      </div>
    </ConfirmationModal>
  );
};

export const ImageAltTextField: FC<{
  imageSrc: string;
  altText: string;
  onChange: (altText: string) => void;
}> = ({ imageSrc, altText, onChange }) => {
  const altLimit = useAppSelector(
    (state) =>
      state.server.getIn(
        ['server', 'configuration', 'media_attachments', 'description_limit'],
        150,
      ) as number,
  );

  const handleChange: ChangeEventHandler<HTMLTextAreaElement> = useCallback(
    (event) => {
      onChange(event.currentTarget.value);
    },
    [onChange],
  );

  return (
    <>
      <img src={imageSrc} alt='' className={classes.altImage} />

      <div>
        <TextAreaField
          label={
            <FormattedMessage
              id='account_edit.image_alt_modal.text_label'
              defaultMessage='Alt text'
            />
          }
          hint={
            <FormattedMessage
              id='account_edit.image_alt_modal.text_hint'
              defaultMessage='Alt text helps screen reader users to understand your content.'
            />
          }
          onChange={handleChange}
          value={altText}
        />
        <CharacterCounter
          currentString={altText}
          maxLength={altLimit}
          className={classes.altCounter}
        />
      </div>

      <Details
        summary={
          <FormattedMessage
            id='account_edit.image_alt_modal.details_title'
            defaultMessage='Tips: Alt text for profile photos'
          />
        }
        className={classes.altHint}
      >
        <FormattedMessage
          id='account_edit.image_alt_modal.details_content'
          defaultMessage='DO: <ul> <li>Describe yourself as pictured</li> <li>Use third person language (e.g. “Alex” instead of “me”)</li> <li>Be succinct – a few words is often enough</li> </ul> DON’T: <ul> <li>Start with “Photo of” – it’s redundant for screen readers</li> </ul> EXAMPLE: <ul> <li>“Alex wearing a green shirt and glasses”</li> </ul>'
          values={{
            ul: (chunks) => <ul>{chunks}</ul>,
            li: (chunks) => <li>{chunks}</li>,
          }}
          tagName='div'
        />
      </Details>
    </>
  );
};
