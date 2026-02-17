import { useCallback, useState } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory, useLocation } from 'react-router-dom';

import type {
  ApiCollectionJSON,
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
} from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import { FormStack, TextAreaField } from 'mastodon/components/form_fields';
import { TextInputField } from 'mastodon/components/form_fields/text_input_field';
import { updateCollection } from 'mastodon/reducers/slices/collections';
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

  const { id, initialName, initialDescription, initialTopic, initialItemIds } =
    getCollectionEditorState(collection, location.state);

  const [name, setName] = useState(initialName);
  const [description, setDescription] = useState(initialDescription);
  const [topic, setTopic] = useState(initialTopic);

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

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();

      if (id) {
        const payload: ApiUpdateCollectionPayload = {
          id,
          name,
          description,
          tag_name: topic || null,
        };

        void dispatch(updateCollection({ payload })).then(() => {
          history.push(`/collections`);
        });
      } else {
        const payload: Partial<ApiCreateCollectionPayload> = {
          name,
          description,
          tag_name: topic || null,
          account_ids: initialItemIds,
        };

        history.replace('/collections/new', payload);
        history.push('/collections/new/settings', payload);
      }
    },
    [id, name, description, topic, dispatch, history, initialItemIds],
  );

  return (
    <FormStack as='form' onSubmit={handleSubmit}>
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

      <div className={classes.actionWrapper}>
        <Button type='submit'>
          {id ? (
            <FormattedMessage id='lists.save' defaultMessage='Save' />
          ) : (
            <FormattedMessage
              id='collections.continue'
              defaultMessage='Continue'
            />
          )}
        </Button>
      </div>
    </FormStack>
  );
};
