import { useCallback, useEffect, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import { Callout } from '@/mastodon/components/callout';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';
import { submitReport } from 'mastodon/actions/reports';
import { fetchServer } from 'mastodon/actions/server';
import type { ApiCollectionJSON } from 'mastodon/api_types/collections';
import { Button } from 'mastodon/components/button';
import { IconButton } from 'mastodon/components/icon_button';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useAppDispatch } from 'mastodon/store';

import Comment from '../../report/comment';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const CollectionThanks: React.FC<{
  onClose: () => void;
}> = ({ onClose }) => {
  return (
    <>
      <h3 className='report-dialog-modal__title'>
        <FormattedMessage
          id='report.thanks.title_actionable'
          defaultMessage="Thanks for reporting, we'll look into this."
        />
      </h3>

      <div className='flex-spacer' />

      <div className='report-dialog-modal__actions'>
        <Button onClick={onClose}>
          <FormattedMessage id='report.close' defaultMessage='Done' />
        </Button>
      </div>
    </>
  );
};

export const ReportCollectionModal: React.FC<{
  collection: ApiCollectionJSON;
  onClose: () => void;
}> = ({ collection, onClose }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();

  const { id: collectionId, name, account_id } = collection;
  const account = useAccount(account_id);

  useEffect(() => {
    dispatch(fetchServer());
  }, [dispatch]);

  const [submitState, setSubmitState] = useState<
    'idle' | 'submitting' | 'submitted' | 'error'
  >('idle');

  const [step, setStep] = useState<'comment' | 'thanks'>('comment');

  const [comment, setComment] = useState('');
  const [selectedDomains, setSelectedDomains] = useState<string[]>([]);

  const handleDomainToggle = useCallback((domain: string, checked: boolean) => {
    if (checked) {
      setSelectedDomains((domains) => [...domains, domain]);
    } else {
      setSelectedDomains((domains) => domains.filter((d) => d !== domain));
    }
  }, []);

  const handleSubmit = useCallback(() => {
    setSubmitState('submitting');

    dispatch(
      submitReport(
        {
          account_id,
          status_ids: [],
          collection_ids: [collectionId],
          forward_to_domains: selectedDomains,
          comment,
          forward: selectedDomains.length > 0,
          category: 'spam',
        },
        () => {
          setSubmitState('submitted');
          setStep('thanks');
        },
        () => {
          setSubmitState('error');
        },
      ),
    );
  }, [account_id, comment, dispatch, collectionId, selectedDomains]);

  if (!account) {
    return null;
  }

  const domain = account.get('acct').split('@')[1];
  const isRemote = !!domain;

  let stepComponent;

  switch (step) {
    case 'comment':
      stepComponent = (
        <Comment
          modalTitle={
            <FormattedMessage
              id='report.collection_comment'
              defaultMessage='Why do you want to report this collection?'
            />
          }
          submitError={
            submitState === 'error' && (
              <Callout
                variant='error'
                title={
                  <FormattedMessage
                    id='report.submission_error'
                    defaultMessage='Report could not be submitted'
                  />
                }
              >
                <FormattedMessage
                  id='report.submission_error_details'
                  defaultMessage='Please check your network connection and try again later.'
                />
              </Callout>
            )
          }
          onSubmit={handleSubmit}
          isSubmitting={submitState === 'submitting'}
          isRemote={isRemote}
          comment={comment}
          domain={domain}
          onChangeComment={setComment}
          statusIds={[]}
          selectedDomains={selectedDomains}
          onToggleDomain={handleDomainToggle}
        />
      );
      break;
    case 'thanks':
      stepComponent = <CollectionThanks onClose={onClose} />;
  }

  return (
    <div className='modal-root__modal report-dialog-modal'>
      <div className='report-modal__target'>
        <IconButton
          className='report-modal__close'
          title={intl.formatMessage(messages.close)}
          icon='times'
          iconComponent={CloseIcon}
          onClick={onClose}
        />
        <FormattedMessage
          id='report.target'
          defaultMessage='Report {target}'
          values={{ target: <strong>{name}</strong> }}
        />
      </div>

      <div className='report-dialog-modal__container'>{stepComponent}</div>
    </div>
  );
};
