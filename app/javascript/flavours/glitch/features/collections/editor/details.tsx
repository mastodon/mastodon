import { useCallback, useMemo } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import {
  hasSpecialCharacters,
  inputToHashtag,
} from '@/flavours/glitch/utils/hashtags';
import type {
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
} from 'flavours/glitch/api_types/collections';
import { Button } from 'flavours/glitch/components/button';
import {
  CheckboxField,
  Fieldset,
  FormStack,
  RadioButtonField,
  TextAreaField,
} from 'flavours/glitch/components/form_fields';
import { TextInputField } from 'flavours/glitch/components/form_fields/text_input_field';
import {
  createCollection,
  updateCollection,
  updateCollectionEditorField,
} from 'flavours/glitch/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'flavours/glitch/store';

import classes from './styles.module.scss';
import { WizardStepHeader } from './wizard_step_header';

export const CollectionDetails: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const history = useHistory();
  const { id, name, description, topic, discoverable, sensitive, accountIds } =
    useAppSelector((state) => state.collections.editor);

  const handleNameChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'name',
          value: event.target.value,
        }),
      );
    },
    [dispatch],
  );

  const handleDescriptionChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'description',
          value: event.target.value,
        }),
      );
    },
    [dispatch],
  );

  const handleTopicChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'topic',
          value: inputToHashtag(event.target.value),
        }),
      );
    },
    [dispatch],
  );

  const handleDiscoverableChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'discoverable',
          value: event.target.value === 'public',
        }),
      );
    },
    [dispatch],
  );

  const handleSensitiveChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'sensitive',
          value: event.target.checked,
        }),
      );
    },
    [dispatch],
  );

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();

      if (id) {
        const payload: ApiUpdateCollectionPayload = {
          id,
          name,
          description,
          tag_name: topic || null,
          discoverable,
          sensitive,
        };

        void dispatch(updateCollection({ payload })).then(() => {
          history.goBack();
        });
      } else {
        const payload: ApiCreateCollectionPayload = {
          name,
          description,
          discoverable,
          sensitive,
          account_ids: accountIds,
        };
        if (topic) {
          payload.tag_name = topic;
        }

        void dispatch(
          createCollection({
            payload,
          }),
        ).then((result) => {
          if (isFulfilled(result)) {
            history.replace(`/collections`);
            history.push(`/collections/${result.payload.collection.id}`, {
              newCollection: true,
            });
          }
        });
      }
    },
    [
      id,
      name,
      description,
      topic,
      discoverable,
      sensitive,
      dispatch,
      history,
      accountIds,
    ],
  );

  const topicHasSpecialCharacters = useMemo(
    () => hasSpecialCharacters(topic),
    [topic],
  );

  return (
    <form onSubmit={handleSubmit} className={classes.form}>
      <FormStack className={classes.formFieldStack}>
        {!id && (
          <WizardStepHeader
            step={2}
            title={
              <FormattedMessage
                id='collections.create.basic_details_title'
                defaultMessage='Basic details'
              />
            }
          />
        )}
        <TextInputField
          required
          label={
            <FormattedMessage
              id='collections.collection_name'
              defaultMessage='Name'
            />
          }
          hint={
            <FormattedMessage
              id='collections.name_length_hint'
              defaultMessage='40 characters limit'
            />
          }
          value={name}
          onChange={handleNameChange}
          maxLength={40}
        />

        <TextAreaField
          required
          label={
            <FormattedMessage
              id='collections.collection_description'
              defaultMessage='Description'
            />
          }
          hint={
            <FormattedMessage
              id='collections.description_length_hint'
              defaultMessage='100 characters limit'
            />
          }
          value={description}
          onChange={handleDescriptionChange}
          maxLength={100}
        />

        <TextInputField
          required={false}
          label={
            <FormattedMessage
              id='collections.collection_topic'
              defaultMessage='Topic'
            />
          }
          hint={
            <FormattedMessage
              id='collections.topic_hint'
              defaultMessage='Add a hashtag that helps others understand the main topic of this collection.'
            />
          }
          value={topic}
          onChange={handleTopicChange}
          autoCapitalize='off'
          autoCorrect='off'
          spellCheck='false'
          maxLength={40}
          status={
            topicHasSpecialCharacters
              ? {
                  variant: 'warning',
                  message: intl.formatMessage({
                    id: 'collections.topic_special_chars_hint',
                    defaultMessage:
                      'Special characters will be removed when saving',
                  }),
                }
              : undefined
          }
        />

        <Fieldset
          legend={
            <FormattedMessage
              id='collections.visibility_title'
              defaultMessage='Visibility'
            />
          }
        >
          <RadioButtonField
            label={
              <FormattedMessage
                id='collections.visibility_public'
                defaultMessage='Public'
              />
            }
            hint={
              <FormattedMessage
                id='collections.visibility_public_hint'
                defaultMessage='Discoverable in search results and other areas where recommendations appear.'
              />
            }
            value='public'
            checked={discoverable}
            onChange={handleDiscoverableChange}
          />
          <RadioButtonField
            label={
              <FormattedMessage
                id='collections.visibility_unlisted'
                defaultMessage='Unlisted'
              />
            }
            hint={
              <FormattedMessage
                id='collections.visibility_unlisted_hint'
                defaultMessage='Visible to anyone with a link. Hidden from search results and recommendations.'
              />
            }
            value='unlisted'
            checked={!discoverable}
            onChange={handleDiscoverableChange}
          />
        </Fieldset>

        <Fieldset
          legend={
            <FormattedMessage
              id='collections.content_warning'
              defaultMessage='Content warning'
            />
          }
        >
          <CheckboxField
            label={
              <FormattedMessage
                id='collections.mark_as_sensitive'
                defaultMessage='Mark as sensitive'
              />
            }
            hint={
              <FormattedMessage
                id='collections.mark_as_sensitive_hint'
                defaultMessage="Hides the collection's description and accounts behind a content warning. The collection name will still be visible."
              />
            }
            checked={sensitive}
            onChange={handleSensitiveChange}
          />
        </Fieldset>
      </FormStack>

      <div className={classes.stickyFooter}>
        <div className={classes.actionWrapper}>
          <Button type='submit'>
            {id ? (
              <FormattedMessage id='lists.save' defaultMessage='Save' />
            ) : (
              <FormattedMessage
                id='collections.create_collection'
                defaultMessage='Create collection'
              />
            )}
          </Button>
        </div>
      </div>
    </form>
  );
};
