import { useCallback, useMemo } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { useHistory } from 'react-router-dom';

import { isFulfilled } from '@reduxjs/toolkit';

import { ComboboxMenuItem } from '@/mastodon/components/form_fields/combobox_field';
import { languages } from '@/mastodon/initial_state';
import {
  hasSpecialCharacters,
  inputToHashtag,
} from '@/mastodon/utils/hashtags';
import type {
  ApiCreateCollectionPayload,
  ApiUpdateCollectionPayload,
} from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import {
  CheckboxField,
  ComboboxField,
  Fieldset,
  FormStack,
  RadioButtonField,
  SelectField,
  TextAreaField,
} from 'mastodon/components/form_fields';
import { TextInputField } from 'mastodon/components/form_fields/text_input_field';
import { useSearchTags } from 'mastodon/hooks/useSearchTags';
import type { TagSearchResult } from 'mastodon/hooks/useSearchTags';
import {
  createCollection,
  updateCollection,
  updateCollectionEditorField,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

import classes from './styles.module.scss';
import { WizardStepTitle } from './wizard_step_title';

export const CollectionDetails: React.FC = () => {
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

  return (
    <form onSubmit={handleSubmit} className={classes.form}>
      <FormStack className={classes.formFieldStack}>
        {!id && (
          <WizardStepTitle
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
          required={false}
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

        <TopicField />

        <LanguageField />

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
    </form>
  );
};

const TopicField: React.FC = () => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const { topic } = useAppSelector((state) => state.collections.editor);

  const { tags, isLoading, searchTags } = useSearchTags({
    query: topic,
  });

  const handleTopicChange = useCallback(
    (event: React.ChangeEvent<HTMLInputElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'topic',
          value: inputToHashtag(event.target.value),
        }),
      );
      searchTags(event.target.value);
    },
    [dispatch, searchTags],
  );

  const handleSelectTopicSuggestion = useCallback(
    (item: TagSearchResult) => {
      dispatch(
        updateCollectionEditorField({
          field: 'topic',
          value: inputToHashtag(item.name),
        }),
      );
    },
    [dispatch],
  );

  const topicHasSpecialCharacters = useMemo(
    () => hasSpecialCharacters(topic),
    [topic],
  );

  const isCurrentTopicOnlySuggestion =
    tags.length === 1 && tags[0]?.id === 'new';
  const hideTagSuggestions = !tags.length || isCurrentTopicOnlySuggestion;

  return (
    <ComboboxField
      required={false}
      icon={null}
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
      items={tags}
      isLoading={isLoading}
      renderItem={renderTagItem}
      onSelectItem={handleSelectTopicSuggestion}
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
      suppressMenu={hideTagSuggestions}
    />
  );
};

const renderTagItem = (item: TagSearchResult) => (
  <ComboboxMenuItem>{item.label ?? `#${item.name}`}</ComboboxMenuItem>
);

const LanguageField: React.FC = () => {
  const dispatch = useAppDispatch();
  const initialLanguage = useAppSelector(
    (state) => state.compose.get('default_language') as string,
  );
  const { language } = useAppSelector((state) => state.collections.editor);

  const selectedLanguage = language ?? initialLanguage;

  const handleLanguageChange = useCallback(
    (event: React.ChangeEvent<HTMLSelectElement>) => {
      dispatch(
        updateCollectionEditorField({
          field: 'language',
          value: event.target.value,
        }),
      );
    },
    [dispatch],
  );

  return (
    <SelectField
      label={
        <FormattedMessage
          id='collections.collection_language'
          defaultMessage='Language'
        />
      }
      value={selectedLanguage}
      onChange={handleLanguageChange}
    >
      <option value=''>
        <FormattedMessage
          id='collections.collection_language_none'
          defaultMessage='None'
        />
      </option>
      {languages?.map(([code, name, localName]) => (
        <option key={code} value={code}>
          {localName} ({name})
        </option>
      ))}
    </SelectField>
  );
};
