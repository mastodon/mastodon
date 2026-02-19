import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory, useLocation } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import type {
  ApiCollectionJSON,
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
} from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import {
  CheckboxField,
  Fieldset,
  FormStack,
  RadioButtonField,
  TextAreaField,
} from 'mastodon/components/form_fields';
import { TextInputField } from 'mastodon/components/form_fields/text_input_field';
import {
  createCollection,
  updateCollection,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch } from 'mastodon/store';

import type { TempCollectionState } from './state';
import { getCollectionEditorState } from './state';
import classes from './styles.module.scss';
import { WizardStepHeader } from './wizard_step_header';

export const CollectionDetails: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const dispatch = useAppDispatch();
  const history = useHistory();
  const location = useLocation<TempCollectionState>();

  const {
    id,
    initialName,
    initialDescription,
    initialTopic,
    initialItemIds,
    initialDiscoverable,
    initialSensitive,
  } = getCollectionEditorState(collection, location.state);

  const [name, setName] = useState(initialName);
  const [description, setDescription] = useState(initialDescription);
  const [topic, setTopic] = useState(initialTopic);
  const [discoverable, setDiscoverable] = useState(initialDiscoverable);
  const [sensitive, setSensitive] = useState(initialSensitive);

  const handleNameChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setName(event.target.value);
    },
    [],
  );

  const handleDescriptionChange = useCallback(
    (event: React.ChangeEvent<HTMLTextAreaElement>) => {
      setDescription(event.target.value);
    },
    [],
  );

  const handleTopicChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setTopic(event.target.value);
    },
    [],
  );

  const handleDiscoverableChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setDiscoverable(event.target.value === 'public');
    },
    [],
  );

  const handleSensitiveChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      setSensitive(event.target.checked);
    },
    [],
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
          account_ids: initialItemIds,
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
            history.replace(
              `/collections/${result.payload.collection.id}/edit/details`,
            );
            history.push(`/collections/${result.payload.collection.id}`);
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
      initialItemIds,
    ],
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
          maxLength={40}
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
