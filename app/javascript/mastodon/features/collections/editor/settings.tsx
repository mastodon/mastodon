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
  Fieldset,
  FormStack,
  CheckboxField,
  RadioButtonField,
} from 'mastodon/components/form_fields';
import {
  createCollection,
  updateCollection,
} from 'mastodon/reducers/slices/collections';
import { useAppDispatch } from 'mastodon/store';

import type { TempCollectionState } from './state';
import { getCollectionEditorState } from './state';
import classes from './styles.module.scss';
import { WizardStepHeader } from './wizard_step_header';

export const CollectionSettings: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const dispatch = useAppDispatch();
  const history = useHistory();
  const location = useLocation<TempCollectionState>();

  const { id, initialDiscoverable, initialSensitive, ...editorState } =
    getCollectionEditorState(collection, location.state);

  const [discoverable, setDiscoverable] = useState(initialDiscoverable);
  const [sensitive, setSensitive] = useState(initialSensitive);

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
          discoverable,
          sensitive,
        };

        void dispatch(updateCollection({ payload })).then(() => {
          history.push(`/collections`);
        });
      } else {
        const payload: ApiCreateCollectionPayload = {
          name: editorState.initialName,
          description: editorState.initialDescription,
          discoverable,
          sensitive,
          account_ids: editorState.initialItemIds,
        };
        if (editorState.initialTopic) {
          payload.tag_name = editorState.initialTopic;
        }

        void dispatch(
          createCollection({
            payload,
          }),
        ).then((result) => {
          if (isFulfilled(result)) {
            history.replace(
              `/collections/${result.payload.collection.id}/edit/settings`,
            );
            history.push(`/collections`);
          }
        });
      }
    },
    [id, discoverable, sensitive, dispatch, history, editorState],
  );

  return (
    <FormStack as='form' onSubmit={handleSubmit}>
      {!id && (
        <WizardStepHeader
          step={3}
          title={
            <FormattedMessage
              id='collections.create.settings_title'
              defaultMessage='Settings'
            />
          }
        />
      )}
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
    </FormStack>
  );
};
