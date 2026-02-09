import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';

import { useHistory, useLocation } from 'react-router-dom';

import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import { FormStack } from 'mastodon/components/form_fields';

import type { TempCollectionState } from './state';
import { getInitialState } from './state';
import { WizardStepHeader } from './wizard_step_header';

export const CollectionAccounts: React.FC<{
  collection?: ApiCollectionJSON | null;
}> = ({ collection }) => {
  const history = useHistory();
  const location = useLocation<TempCollectionState>();

  const { id } = getInitialState(collection, location.state);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();

      if (!id) {
        history.push(`/collections/new/details`);
      }
    },
    [id, history],
  );

  return (
    <FormStack as='form' onSubmit={handleSubmit}>
      {!id && (
        <WizardStepHeader
          step={1}
          title={
            <FormattedMessage
              id='collections.create.accounts_title'
              defaultMessage='Who will you feature in this collection?'
            />
          }
          description={
            <FormattedMessage
              id='collections.create.accounts_subtitle'
              defaultMessage='Only accounts you follow who have opted into discovery can be added.'
            />
          }
        />
      )}
      <div className='actions'>
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
